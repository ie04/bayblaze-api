import Busboy from "busboy";
import { Router, type Request, type Response as ExpressResponse } from "express";

import {
  forwardInventoryImageCleanup,
  forwardInventoryImageRead,
  forwardInventoryImageUpload,
  forwardInventoryRequest,
} from "../../clients/medusaInventoryClient";
import { requireInventoryAppToken } from "../../http/middleware/inventoryAppAuth";

type ParsedUpload = {
  buffer: Buffer;
  fileName: string;
  mimeType: string;
};

export function createInventoryBridgeRouter() {
  const router = Router();

  router.get("/inventory", requireInventoryAppToken, async (req, res, next) => {
    try {
      const upstream = await forwardInventoryRequest(req);
      await sendUpstreamJson(res, upstream, "Medusa inventory API returned a non-JSON response.");
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/inventory", requireInventoryAppToken, async (req, res, next) => {
    try {
      const upstream = await forwardInventoryRequest(req);
      await sendUpstreamJson(res, upstream, "Medusa inventory API returned a non-JSON response.");
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/inventory/images", requireInventoryAppToken, async (req, res, next) => {
    try {
      const upload = await readMultipartImageUpload(req);
      const formData = new FormData();

      formData.append(
        "image",
        new Blob([new Uint8Array(upload.buffer)], { type: upload.mimeType }),
        upload.fileName,
      );

      const upstream = await forwardInventoryImageUpload(formData);
      await sendUpstreamJson(res, upstream, "Medusa inventory image API returned a non-JSON response.");
    } catch (caught) {
      next(caught);
    }
  });

  router.get("/inventory/images/:filename", requireInventoryAppToken, async (req, res, next) => {
    try {
      const filename = readSafeImageFilename(req.params.filename);

      if (!filename) {
        res.status(400).json({
          message: "Inventory image filename is invalid.",
        });
        return;
      }

      const upstream = await forwardInventoryImageRead(filename);

      await sendUpstreamBinary(res, upstream);
    } catch (caught) {
      next(caught);
    }
  });

  router.delete("/inventory/images", requireInventoryAppToken, async (req, res, next) => {
    try {
      const rawBody = await readJsonOrRawBody(req);
      const upstream = await forwardInventoryImageCleanup(rawBody);

      await sendUpstreamJson(res, upstream, "Medusa inventory image API returned a non-JSON response.");
    } catch (caught) {
      next(caught);
    }
  });

  return router;
}

async function sendUpstreamJson(res: ExpressResponse, upstream: globalThis.Response, nonJsonMessage: string) {
  const responseText = await upstream.text();
  let responseBody: { message?: unknown } | Record<string, unknown>;

  try {
    responseBody = responseText ? JSON.parse(responseText) : {};
  } catch {
    responseBody = {
      message: responseText || nonJsonMessage,
    };
  }

  if (!upstream.ok && typeof responseBody.message !== "string") {
    responseBody = {
      ...responseBody,
      message: `Upstream inventory request failed with HTTP ${upstream.status}.`,
    };
  }

  return res.status(upstream.status).json(responseBody);
}

async function sendUpstreamBinary(res: ExpressResponse, upstream: globalThis.Response) {
  const body = Buffer.from(await upstream.arrayBuffer());
  const contentType = upstream.headers.get("content-type");
  const cacheControl = upstream.headers.get("cache-control");

  if (contentType) {
    res.setHeader("Content-Type", contentType);
  }

  if (cacheControl) {
    res.setHeader("Cache-Control", cacheControl);
  }

  return res.status(upstream.status).send(body);
}

function readMultipartImageUpload(req: Request) {
  return new Promise<ParsedUpload>((resolve, reject) => {
    const contentType = readHeader(req.headers["content-type"]);

    if (!contentType.includes("multipart/form-data")) {
      reject(new Error("Inventory image upload must be multipart/form-data."));
      return;
    }

    const parser = Busboy({
      headers: {
        "content-type": contentType,
      },
      limits: {
        files: 1,
        fileSize: 2 * 1024 * 1024,
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

    req.pipe(parser);
  });
}

async function readJsonOrRawBody(req: Request) {
  if (req.body && typeof req.body === "object") {
    return JSON.stringify(req.body);
  }

  return readRawBody(req);
}

function readRawBody(req: Request) {
  return new Promise<string>((resolve, reject) => {
    const chunks: Buffer[] = [];

    req.on("data", (chunk: Buffer) => {
      chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
    });

    req.on("error", (error) => {
      reject(error instanceof Error ? error : new Error("Unable to read request body."));
    });

    req.on("end", () => {
      resolve(Buffer.concat(chunks).toString("utf8"));
    });
  });
}

function readSafeImageFilename(value: unknown) {
  const filename = readHeader(value);

  if (!/^[a-zA-Z0-9._-]+\.(jpg|jpeg|png|webp|gif)$/i.test(filename)) {
    return "";
  }

  return filename;
}

function readHeader(value: unknown) {
  if (Array.isArray(value)) {
    return value[0] ?? "";
  }

  return typeof value === "string" ? value : "";
}
