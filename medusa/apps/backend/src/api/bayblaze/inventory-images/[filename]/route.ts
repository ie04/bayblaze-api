import { readFile } from "node:fs/promises";
import path from "node:path";

import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http";

export const AUTHENTICATE = false;

export async function GET(req: MedusaRequest, res: MedusaResponse) {
  const filename = typeof req.params?.filename === "string" ? req.params.filename : "";

  if (!/^[a-zA-Z0-9._-]+$/.test(filename)) {
    return res.status(404).send("Not found");
  }

  const uploadDir = getInventoryImageUploadDir();
  const resolvedPath = path.resolve(uploadDir, filename);
  const resolvedUploadDir = path.resolve(uploadDir);

  if (!resolvedPath.startsWith(`${resolvedUploadDir}${path.sep}`)) {
    return res.status(404).send("Not found");
  }

  try {
    const file = await readFile(resolvedPath);

    res.setHeader("Cache-Control", "public, max-age=31536000, immutable");
    res.setHeader("Content-Type", getContentType(filename));

    return res.status(200).send(file);
  } catch {
    return res.status(404).send("Not found");
  }
}

function getInventoryImageUploadDir() {
  return process.env.BAYBLAZE_INVENTORY_IMAGE_UPLOAD_DIR || path.join(process.cwd(), "uploads", "bayblaze-inventory");
}

function getContentType(filename: string) {
  const extension = path.extname(filename).toLowerCase();

  if (extension === ".jpg" || extension === ".jpeg") {
    return "image/jpeg";
  }

  if (extension === ".png") {
    return "image/png";
  }

  if (extension === ".webp") {
    return "image/webp";
  }

  if (extension === ".gif") {
    return "image/gif";
  }

  return "application/octet-stream";
}
