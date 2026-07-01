const fs = require("node:fs/promises");
const fsSync = require("node:fs");
const path = require("node:path");
const express = require("express");
const { getPrinters, print } = require("pdf-to-printer");

const { buildDeliveryLabelPreviewHtml } = require("./delivery-label-template");
const { renderInvoicePdf, renderLabelPdf } = require("./label-renderer");

loadEnvFile();

const config = {
  port: parseInteger(process.env.LABEL_AGENT_PORT, 4786),
  token:
    process.env.LABEL_AGENT_TOKEN?.trim() ||
    process.env.LABEL_PRINTER_AGENT_TOKEN?.trim() ||
    "",
  printerName: process.env.LABEL_PRINTER_NAME?.trim() || undefined,
  dpi: parseInteger(process.env.LABEL_DPI, 203),
  dataDir: path.resolve(process.env.LABEL_DATA_DIR || path.join(__dirname, "..", "data")),
  keepFiles: process.env.LABEL_KEEP_FILES === "true",
};

const activePrintJobs = new Set();

function loadEnvFile() {
  const envPath = path.join(__dirname, "..", ".env");

  if (typeof process.loadEnvFile === "function") {
    try {
      process.loadEnvFile(envPath);
    } catch (error) {
      if (error.code !== "ENOENT") {
        throw error;
      }
    }

    return;
  }

  try {
    const envFile = fsSync.readFileSync(envPath, "utf8");

    for (const line of envFile.split(/\r?\n/)) {
      const match = line.match(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)?\s*$/);

      if (!match || process.env[match[1]] !== undefined) {
        continue;
      }

      process.env[match[1]] = stripEnvValueQuotes(match[2] ?? "");
    }
  } catch (error) {
    if (error.code !== "ENOENT") {
      throw error;
    }
  }
}

function stripEnvValueQuotes(value) {
  const trimmed = value.trim();
  const quote = trimmed[0];

  if ((quote === "\"" || quote === "'") && trimmed.endsWith(quote)) {
    return trimmed.slice(1, -1);
  }

  return trimmed;
}

if (process.argv.includes("--list-printers")) {
  listPrintersAndExit();
} else {
  startServer();
}

function startServer() {
  const app = express();

  app.use(express.json({ limit: "1mb" }));

  app.get("/health", async (_req, res) => {
    res.status(200).json({
      ok: true,
      printerName: config.printerName ?? null,
    });
  });

  app.get("/preview-label", (req, res) => {
    const orderId = String(req.query.order_id || req.query.orderId || "").trim();
    const shipTo = String(req.query.ship_to || req.query.shipTo || "").trim();
    const instructions = String(req.query.instructions || "").trim();
    const address = String(req.query.address || "").trim();

    res
      .type("html")
      .send(
        buildDeliveryLabelPreviewHtml({
          orderId,
          shipTo,
          instructions,
          address,
        }),
      );
  });

  app.get("/printers", requireAuth, async (_req, res, next) => {
    try {
      res.status(200).json({ printers: await getPrinters() });
    } catch (error) {
      next(error);
    }
  });

  app.post("/print-label", requireAuth, async (req, res, next) => {
    let job;

    try {
      job = validateJob(req.body);
      const dedupeKey = getPrintDedupeKey(job);
      console.log(`[Label Agent] Print request received: ${job.jobId} (${dedupeKey})`);

      if (activePrintJobs.has(dedupeKey)) {
        return res.status(200).json({
          ok: true,
          skipped: true,
          reason: "Job already in progress.",
        });
      }

      activePrintJobs.add(dedupeKey);

      const printedJobs = await readPrintedJobs();

      if (
        !job.forceReprint &&
        (printedJobs[dedupeKey] || printedJobs[job.jobId] || hasPrintedOrder(printedJobs, job))
      ) {
        return res.status(200).json({
          ok: true,
          skipped: true,
          reason: "Job already printed.",
        });
      }

      const pdfPath = path.join(
        config.dataDir,
        "jobs",
        `${safeFilename(job.jobId)}.pdf`,
      );

      if (job.jobType === "invoice") {
        await renderInvoicePdf(job, pdfPath, { dpi: config.dpi });
      } else {
        await renderLabelPdf(job, pdfPath, { dpi: config.dpi });
      }

      console.log(`[Label Agent] Sending to printer: ${job.jobId}`);

      await print(pdfPath, {
        printer: config.printerName,
        orientation: "portrait",
        scale: "noscale",
        copies: 1,
      });

      const latestPrintedJobs = await readPrintedJobs();
      const printedJobRecord = {
        jobId: job.jobId,
        jobType: job.jobType,
        orderId: job.orderId,
        orderNumber: job.orderNumber,
        printedAt: new Date().toISOString(),
      };
      latestPrintedJobs[dedupeKey] = printedJobRecord;
      latestPrintedJobs[job.jobId] = printedJobRecord;
      await writePrintedJobs(latestPrintedJobs);

      if (!config.keepFiles) {
        await fs.rm(pdfPath, { force: true });
      }

      res.status(200).json({ ok: true, skipped: false });
    } catch (error) {
      next(error);
    } finally {
      if (job) {
        activePrintJobs.delete(getPrintDedupeKey(job));
      }
    }
  });

  app.use((error, _req, res, _next) => {
    console.error(error);
    res.status(error.statusCode || 500).json({
      error: error.message || "Could not print label.",
    });
  });

  app.listen(config.port, "0.0.0.0", () => {
    console.log(`Bayblaze label printer agent listening on port ${config.port}.`);
    if (!config.token) {
      console.warn("LABEL_AGENT_TOKEN is not set. LAN clients can submit print jobs.");
    }
  });
}

function requireAuth(req, res, next) {
  if (!config.token) {
    return next();
  }

  const bearerToken = req.get("authorization")?.match(/^Bearer\s+(.+)$/i)?.[1];
  const headerToken = req.get("x-label-printer-token");

  if (bearerToken === config.token || headerToken === config.token) {
    return next();
  }

  return res.status(401).json({ error: "Unauthorized." });
}

function getPrintDedupeKey(job) {
  return `order:${job.orderId}:${job.jobType}`;
}

function hasPrintedOrder(printedJobs, job) {
  return Object.values(printedJobs).some((printedJob) => {
    return (
      printedJob &&
      printedJob.orderId === job.orderId &&
      (printedJob.jobType || "delivery_label") === job.jobType
    );
  });
}

function validateJob(body) {
  const job = body && typeof body === "object" ? body : {};
  const requiredFields = ["jobId", "orderId", "orderNumber", "orderUrl", "customerName"];

  for (const field of requiredFields) {
    if (typeof job[field] !== "string" || !job[field].trim()) {
      const error = new Error(`Missing ${field}.`);
      error.statusCode = 400;
      throw error;
    }
  }

  const address = Array.isArray(job.address)
    ? job.address.map((line) => String(line ?? "").trim()).filter(Boolean)
    : [];
  const rawJobType = String(job.jobType || job.type || "").trim();
  const jobType = rawJobType === "invoice" ? "invoice" : "delivery_label";

  return {
    jobId: job.jobId.trim(),
    jobType,
    orderId: job.orderId.trim(),
    orderNumber: job.orderNumber.trim(),
    orderUrl: job.orderUrl.trim(),
    customerName: job.customerName.trim(),
    customerPhone: typeof job.customerPhone === "string" ? job.customerPhone.trim() : "",
    customerEmail: typeof job.customerEmail === "string" ? job.customerEmail.trim() : "",
    currencyCode: typeof job.currencyCode === "string" && job.currencyCode.trim()
      ? job.currencyCode.trim().toUpperCase()
      : "USD",
    instructions: typeof job.instructions === "string" ? job.instructions.trim() : "",
    address: address.length ? address : ["Address unavailable"],
    items: normalizeInvoiceItems(job.items),
    totals: normalizeInvoiceTotals(job.totals),
    paymentMethod: typeof job.paymentMethod === "string" && job.paymentMethod.trim()
      ? job.paymentMethod.trim()
      : "Pay on delivery",
    forceReprint: job.forceReprint === true,
  };
}

function normalizeInvoiceItems(items) {
  return Array.isArray(items)
    ? items.map((item) => ({
        title: String(item?.title ?? "Item").trim() || "Item",
        variantTitle: String(item?.variantTitle ?? "").trim(),
        quantity: Number.isFinite(Number(item?.quantity)) ? Number(item.quantity) : 0,
        unitPrice: Number.isFinite(Number(item?.unitPrice)) ? Number(item.unitPrice) : 0,
        total: Number.isFinite(Number(item?.total)) ? Number(item.total) : 0,
      }))
    : [];
}

function normalizeInvoiceTotals(totals) {
  const source = totals && typeof totals === "object" ? totals : {};

  return {
    subtotal: Number.isFinite(Number(source.subtotal)) ? Number(source.subtotal) : 0,
    discountTotal: Number.isFinite(Number(source.discountTotal)) ? Number(source.discountTotal) : 0,
    shippingTotal: Number.isFinite(Number(source.shippingTotal)) ? Number(source.shippingTotal) : 0,
    taxTotal: Number.isFinite(Number(source.taxTotal)) ? Number(source.taxTotal) : 0,
    total: Number.isFinite(Number(source.total)) ? Number(source.total) : 0,
  };
}

async function readPrintedJobs() {
  const filePath = printedJobsPath();

  try {
    const contents = await fs.readFile(filePath, "utf8");
    const trimmed = contents.trim();

    return trimmed ? JSON.parse(trimmed) : {};
  } catch (error) {
    if (error.code === "ENOENT") {
      return {};
    }

    if (error instanceof SyntaxError) {
      const corruptPath = `${filePath}.corrupt-${Date.now()}`;
      await fs.rename(filePath, corruptPath).catch(() => {});
      console.warn(
        `[Label Agent] printed-jobs.json was corrupt and has been moved to ${corruptPath}. Starting with an empty print history.`,
      );
      return {};
    }

    throw error;
  }
}

async function writePrintedJobs(jobs) {
  const filePath = printedJobsPath();
  const tempPath = `${filePath}.tmp`;

  await fs.mkdir(path.dirname(filePath), { recursive: true });
  await fs.writeFile(tempPath, `${JSON.stringify(jobs, null, 2)}\n`);
  await fs.rename(tempPath, filePath);
}

function printedJobsPath() {
  return path.join(config.dataDir, "printed-jobs.json");
}

function safeFilename(value) {
  return value.replace(/[^a-z0-9._-]+/gi, "_");
}

function parseInteger(value, fallback) {
  const parsed = Number.parseInt(value ?? "", 10);

  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}

async function listPrintersAndExit() {
  const printers = await getPrinters();

  for (const printer of printers) {
    console.log(printer.name);
  }
}
