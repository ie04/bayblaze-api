import crypto from "node:crypto";
import { mkdir, readdir, stat, unlink, writeFile } from "node:fs/promises";
import path from "node:path";

import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http";
import Busboy from "busboy";

import { assertBayblazeServiceToken } from "../../../../lib/bayblaze-service-auth";

export const AUTHENTICATE = false;

type ProductImageUploadDraft = {
  dataUrl?: string;
  fileName?: string;
  mimeType?: string;
};

type ParsedMultipartUpload = {
  buffer: Buffer;
  fileName: string;
  mimeType: string;
};

type PipeableRequest = {
  pipe: (destination: NodeJS.WritableStream) => void;
};

export async function POST(req: MedusaRequest, res: MedusaResponse) {
  if (!assertBayblazeServiceToken(req, res)) {
    return;
  }

  try {
    await cleanupStaleTemporaryImages();

    const contentType = readHeader(req.headers["content-type"]);
    const url = contentType.includes("multipart/form-data")
      ? await saveTemporaryMultipartUpload(req)
      : await saveTemporaryJsonUpload(req);

    return res.status(200).json({ temporary: true, url });
  } catch (caught) {
    console.error("BayBlaze inventory image upload failed:", caught);

    return res.status(400).json({
      message: caught instanceof Error ? caught.message : "Inventory image upload failed.",
    });
  }
}

export async function DELETE(req: MedusaRequest, res: MedusaResponse) {
  if (!assertBayblazeServiceToken(req, res)) {
    return;
  }

  try {
    const body = req.body as { url?: unknown; urls?: unknown } | undefined;
    const urls = Array.isArray(body?.urls)
      ? body.urls
      : typeof body?.url === "string"
        ? [body.url]
        : [];

    const deleted = await deleteTemporaryProductImageUrls(urls);

    return res.status(200).json({ deleted });
  } catch (caught) {
    console.error("BayBlaze inventory temporary image cleanup failed:", caught);

    return res.status(400).json({
      message: caught instanceof Error ? caught.message : "Inventory temporary image cleanup failed.",
    });
  }
}

async function saveTemporaryMultipartUpload(req: MedusaRequest) {
  const upload = await readMultipartImageUpload(req);

  return saveTemporaryProductImageBuffer(req, upload.buffer, upload.mimeType);
}

async function saveTemporaryJsonUpload(req: MedusaRequest) {
  const body = req.body as { imageUpload?: ProductImageUploadDraft } | undefined;
  const imageUpload = body?.imageUpload;

  if (!imageUpload) {
    throw new Error("Product image upload is required.");
  }

  const dataUrl = readString(imageUpload.dataUrl);
  const match = dataUrl.match(/^data:(image\/[a-zA-Z0-9.+-]+);base64,([a-zA-Z0-9+/=\r\n]+)$/);

  if (!match) {
    throw new Error("Product image upload must be a base64 image data URL.");
  }

  const bytes = Buffer.from(match[2].replace(/\s/g, ""), "base64");
  const mimeType = readString(imageUpload.mimeType, match[1]);

  return saveTemporaryProductImageBuffer(req, bytes, mimeType);
}

function readMultipartImageUpload(req: MedusaRequest) {
  return new Promise<ParsedMultipartUpload>((resolve, reject) => {
    const contentType = readHeader(req.headers["content-type"]);

    if (!contentType.includes("multipart/form-data")) {
      reject(new Error("Product image upload must be multipart/form-data."));
      return;
    }

    const maxBytes = Number(process.env.BAYBLAZE_INVENTORY_IMAGE_MAX_BYTES ?? 900 * 1024);
    const parser = Busboy({
      headers: { "content-type": contentType },
      limits: {
        files: 1,
        fileSize: maxBytes,
      },
    });

    const chunks: Buffer[] = [];
    let fileName = "product-photo.jpg";
    let mimeType = "image/jpeg";
    let sawImage = false;
    let settled = false;

    function fail(error: Error) {
      if (settled) {
        return;
      }

      settled = true;
      reject(error);
    }

    parser.on("file", (fieldName, file, info) => {
      if (fieldName !== "image") {
        file.resume();
        return;
      }

      sawImage = true;
      fileName = info.filename || fileName;
      mimeType = info.mimeType || mimeType;

      file.on("data", (chunk: Buffer) => {
        chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
      });

      file.on("limit", () => {
        fail(new Error("Product image is too large."));
      });

      file.on("error", (error) => {
        fail(error instanceof Error ? error : new Error("Product image stream failed."));
      });
    });

    parser.on("error", (error) => {
      fail(error instanceof Error ? error : new Error("Product image upload parsing failed."));
    });

    parser.on("finish", () => {
      if (settled) {
        return;
      }

      if (!sawImage || chunks.length === 0) {
        fail(new Error("Product image upload is required."));
        return;
      }

      settled = true;
      resolve({
        buffer: Buffer.concat(chunks),
        fileName,
        mimeType,
      });
    });

    (req as unknown as PipeableRequest).pipe(parser as unknown as NodeJS.WritableStream);
  });
}

async function saveTemporaryProductImageBuffer(
  req: MedusaRequest,
  bytes: Buffer,
  mimeType: string,
) {
  const extension = getImageExtension(mimeType);

  if (!extension) {
    throw new Error("Product image must be a JPG, PNG, WebP, or GIF file.");
  }

  const maxBytes = Number(process.env.BAYBLAZE_INVENTORY_IMAGE_MAX_BYTES ?? 900 * 1024);

  if (bytes.length > maxBytes) {
    throw new Error("Product image is too large.");
  }

  const fileName = `tmp-${Date.now()}-${crypto.randomUUID()}.${extension}`;
  const uploadDir = getInventoryImageUploadDir();

  await mkdir(uploadDir, { recursive: true });
  await writeFile(path.join(uploadDir, fileName), bytes);

  const publicOrigin = getPublicOrigin(req);

  if (!publicOrigin) {
    throw new Error("Unable to determine public Medusa URL for uploaded product image.");
  }

  return `${publicOrigin}/bayblaze/inventory-images/${fileName}`;
}

async function deleteTemporaryProductImageUrls(urls: unknown[]) {
  const uniqueFileNames = Array.from(
    new Set(
      urls
        .map((url) => getTemporaryInventoryImageFileName(readString(url)))
        .filter((fileName): fileName is string => Boolean(fileName)),
    ),
  );

  let deleted = 0;

  for (const fileName of uniqueFileNames) {
    try {
      await unlink(path.join(getInventoryImageUploadDir(), fileName));
      deleted += 1;
    } catch {
      // Cleanup is idempotent.
    }
  }

  return deleted;
}

async function cleanupStaleTemporaryImages() {
  const uploadDir = getInventoryImageUploadDir();
  const maxAgeMs = Number(process.env.BAYBLAZE_INVENTORY_TEMP_IMAGE_MAX_AGE_MS ?? 24 * 60 * 60 * 1000);
  const cutoff = Date.now() - maxAgeMs;

  let entries: string[] = [];

  try {
    entries = await readdir(uploadDir);
  } catch {
    return;
  }

  await Promise.all(
    entries
      .filter((entry) => isTemporaryInventoryImageFileName(entry))
      .map(async (entry) => {
        const filePath = path.join(uploadDir, entry);

        try {
          const fileStat = await stat(filePath);

          if (fileStat.mtimeMs < cutoff) {
            await unlink(filePath);
          }
        } catch {
          // Best-effort cleanup only.
        }
      }),
  );
}

function getTemporaryInventoryImageFileName(url: string) {
  if (!url) {
    return "";
  }

  let fileName = "";

  try {
    const parsed = new URL(url);
    fileName = path.basename(parsed.pathname);
  } catch {
    fileName = path.basename(url);
  }

  return isTemporaryInventoryImageFileName(fileName) ? fileName : "";
}

function isTemporaryInventoryImageFileName(fileName: string) {
  return /^tmp-[a-zA-Z0-9._-]+\.(jpg|jpeg|png|webp|gif)$/i.test(fileName);
}

function getInventoryImageUploadDir() {
  return process.env.BAYBLAZE_INVENTORY_IMAGE_UPLOAD_DIR || path.join(process.cwd(), "uploads", "bayblaze-inventory");
}

function getPublicOrigin(req: MedusaRequest) {
  const configuredOrigin = readString(
    process.env.BAYBLAZE_PUBLIC_MEDUSA_URL,
    process.env.MEDUSA_PUBLIC_URL,
    process.env.BACKEND_URL,
    process.env.MEDUSA_BACKEND_URL,
  );

  if (configuredOrigin) {
    return configuredOrigin.replace(/\/$/, "");
  }

  const host = readString(req.headers["x-forwarded-host"], req.headers.host);
  const protocol = readString(req.headers["x-forwarded-proto"]) || "https";

  return host ? `${protocol}://${host}` : "";
}

function getImageExtension(mimeType: string) {
  const normalized = mimeType.toLowerCase();

  if (normalized === "image/jpeg" || normalized === "image/jpg") {
    return "jpg";
  }

  if (normalized === "image/png") {
    return "png";
  }

  if (normalized === "image/webp") {
    return "webp";
  }

  if (normalized === "image/gif") {
    return "gif";
  }

  return "";
}

function readHeader(value: unknown) {
  if (Array.isArray(value)) {
    return value[0] ?? "";
  }

  return typeof value === "string" ? value : "";
}

function readString(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === "string" && value.trim()) {
      return value.trim();
    }
  }

  return "";
}
