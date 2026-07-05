const fs = require("node:fs/promises");
const path = require("node:path");
const PDFDocument = require("pdfkit");

const {
  BAYBLAZE_LOGO_PATH,
  JOST_BOLD_PATH,
  JOST_EXTRABOLD_PATH,
  JOST_SEMIBOLD_PATH,
  LABEL_FRAME_HEIGHT_PX,
  LABEL_FRAME_WIDTH_PX,
  LABEL_HEIGHT_IN,
  LABEL_WIDTH_IN,
  ROBOTO_CONDENSED_BOLD_PATH,
  ROBOTO_MEDIUM_PATH,
} = require("./delivery-label-template");
const { buildStyledQrBuffer, defaultQrLogoPath } = require("./qr");

const PDF_WIDTH_PT = LABEL_WIDTH_IN * 72;
const PDF_HEIGHT_PT = LABEL_HEIGHT_IN * 72;
const PX_TO_PT = PDF_WIDTH_PT / LABEL_FRAME_WIDTH_PX;

async function renderLabelPdf(job, outputPath, options = {}) {
  const qrLogoPath = options.qrLogoPath || defaultQrLogoPath();
  const qrBuffer = await buildStyledQrBuffer(job.orderUrl, qrLogoPath);
  const labelData = normalizeLabelJob(job);

  await writePdf(outputPath, (doc) => {
    drawDeliveryLabel(doc, labelData, qrBuffer);
  });

  return outputPath;
}

async function renderInvoicePdf(job, outputPath) {
  const invoiceData = normalizeInvoiceJob(job);

  await writePdf(outputPath, (doc) => {
    drawInvoice(doc, invoiceData);
  });

  return outputPath;
}

async function writePdf(outputPath, draw) {
  await fs.mkdir(path.dirname(outputPath), { recursive: true });

  await new Promise((resolve, reject) => {
    const doc = new PDFDocument({
      size: [PDF_WIDTH_PT, PDF_HEIGHT_PT],
      margin: 0,
      autoFirstPage: true,
    });
    const chunks = [];

    doc.on("data", (chunk) => chunks.push(chunk));
    doc.on("end", () => {
      fs.writeFile(outputPath, Buffer.concat(chunks)).then(resolve, reject);
    });
    doc.on("error", reject);

    draw(doc);

    doc.end();
  });
}

function drawDeliveryLabel(doc, labelData, qrBuffer) {
  registerFonts(doc);

  doc.rect(0, 0, pt(LABEL_FRAME_WIDTH_PX), pt(LABEL_FRAME_HEIGHT_PX)).fill("#fff");
  strokeRect(doc, 40, 40, 732, 1138, 3);
  strokeRect(doc, 420, 825, 320, 320, 3);
  strokeRect(doc, 40, 340, 732, 81, 3);

  doc.image(BAYBLAZE_LOGO_PATH, pt(192), pt(50), {
    width: pt(427),
    height: pt(203),
  });

  drawSingleLine(doc, "DELIVERY LABEL", {
    x: 201,
    y: 260,
    width: 409,
    height: 68,
    font: "Jost-ExtraBold",
    size: 48,
    lineHeight: 69,
  });
  drawOrderId(doc, labelData.orderId);
  drawLabelValue(doc, {
    x: 56,
    y: 449,
    width: 339,
    height: 219,
    label: "SHIP TO:",
    value: labelData.shipTo,
  });
  drawLabelValue(doc, {
    x: 406,
    y: 448,
    width: 340,
    height: 335,
    label: "INSTRUCTIONS:",
    value: labelData.instructions,
  });
  drawLabelValue(doc, {
    x: 56,
    y: 668,
    width: 350,
    height: 510,
    label: "ADDRESS:",
    value: labelData.address,
  });
  drawSingleLine(doc, "SCAN QR TO VIEW ORDER DETAILS", {
    x: 411,
    y: 796,
    width: 338,
    height: 29,
    font: "Jost-SemiBold",
    size: 20,
    lineHeight: 29,
  });

  doc.image(qrBuffer, pt(423), pt(828), {
    width: pt(314),
    height: pt(314),
  });
}


const INVOICE_MARGIN_X = 54;
const INVOICE_CONTENT_WIDTH = LABEL_FRAME_WIDTH_PX - INVOICE_MARGIN_X * 2;
const INVOICE_MAX_ITEM_ROWS = 6;

function drawInvoice(doc, invoiceData) {
  registerFonts(doc);

  doc.rect(0, 0, pt(LABEL_FRAME_WIDTH_PX), pt(LABEL_FRAME_HEIGHT_PX)).fill("#fff");
  strokeRect(doc, 36, 36, LABEL_FRAME_WIDTH_PX - 72, LABEL_FRAME_HEIGHT_PX - 72, 3);

  let y = 56;

  y = drawFlowText(doc, "BAYBLAZE", {
    y,
    font: "Jost-ExtraBold",
    size: 40,
    lineHeight: 48,
    align: "center",
  });
  y = drawFlowText(doc, "DELIVERY INVOICE", {
    y: y - 2,
    font: "Jost-Bold",
    size: 26,
    lineHeight: 34,
    align: "center",
  });

  y = drawDivider(doc, y + 8);

  y = drawFlowText(doc, `Order: ${invoiceData.orderNumber}`, {
    y: y + 12,
    font: "Jost-SemiBold",
    size: 24,
    lineHeight: 32,
  });
  y = drawFlowText(doc, `Date: ${formatInvoiceDate(new Date())}`, {
    y,
    size: 19,
    lineHeight: 27,
  });

  y = drawSectionTitle(doc, "Customer", y + 8);
  y = drawFlowText(
    doc,
    [
      invoiceData.customerName,
      invoiceData.customerPhone,
      invoiceData.customerEmail,
    ].filter(Boolean).join("\n"),
    {
      y,
      size: 19,
      lineHeight: 25,
    },
  );

  y = drawSectionTitle(doc, "Delivery Address", y + 8);
  y = drawFlowText(doc, invoiceData.address.join("\n") || "Address unavailable", {
    y,
    size: 19,
    lineHeight: 25,
  });

  y = drawDivider(doc, y + 10);
  y = drawSectionTitle(doc, "Items", y + 10);

  const itemRows = invoiceData.items.slice(0, INVOICE_MAX_ITEM_ROWS);
  for (const item of itemRows) {
    const itemName = [item.title, item.variantTitle].filter(Boolean).join(" - ");
    const left = `${item.quantity} x ${itemName}`;
    const right = formatInvoiceMoney(item.total, invoiceData.currencyCode);
    y = drawInvoiceRow(doc, left, right, y, {
      leftWidth: 500,
      rightWidth: 166,
      size: 18,
      lineHeight: 24,
    });
  }

  if (invoiceData.items.length > INVOICE_MAX_ITEM_ROWS) {
    y = drawFlowText(doc, `+ ${invoiceData.items.length - INVOICE_MAX_ITEM_ROWS} more item(s)`, {
      y,
      size: 17,
      lineHeight: 23,
    });
  }

  const totalsY = Math.min(Math.max(y + 12, 790), 870);
  y = drawDivider(doc, totalsY);
  y = drawInvoiceRow(doc, "Subtotal", formatInvoiceMoney(invoiceData.totals.subtotal, invoiceData.currencyCode), y + 10);
  if (invoiceData.totals.discountTotal > 0) {
    y = drawInvoiceRow(
      doc,
      invoiceData.totals.discountLabel || "Discount",
      formatInvoiceMoney(-invoiceData.totals.discountTotal, invoiceData.currencyCode),
      y,
    );
  }
  if (invoiceData.totals.shippingTotal > 0) {
    y = drawInvoiceRow(doc, "Delivery", formatInvoiceMoney(invoiceData.totals.shippingTotal, invoiceData.currencyCode), y);
  }
  if (invoiceData.totals.taxTotal > 0) {
    y = drawInvoiceRow(doc, "Tax", formatInvoiceMoney(invoiceData.totals.taxTotal, invoiceData.currencyCode), y);
  }
  y = drawInvoiceRow(doc, "TOTAL DUE", formatInvoiceMoney(invoiceData.totals.total, invoiceData.currencyCode), y + 8, {
    font: "Jost-Bold",
    size: 23,
    lineHeight: 31,
  });

  y = drawFlowText(doc, `Payment: ${invoiceData.paymentMethod}`, {
    y: y + 6,
    font: "Jost-SemiBold",
    size: 19,
    lineHeight: 27,
  });

  drawFlowText(doc, "Customer Signature:", {
    y: 1018,
    font: "RobotoCondensed-Bold",
    size: 24,
    lineHeight: 32,
  });

  doc
    .save()
    .lineWidth(pt(3))
    .moveTo(pt(INVOICE_MARGIN_X), pt(1094))
    .lineTo(pt(INVOICE_MARGIN_X + INVOICE_CONTENT_WIDTH), pt(1094))
    .strokeColor("#000")
    .stroke()
    .restore();

  drawFlowText(doc, "I acknowledge receipt of this order.", {
    y: 1120,
    size: 18,
    lineHeight: 24,
    align: "center",
  });
}

function drawSectionTitle(doc, label, y) {
  return drawFlowText(doc, label.toUpperCase(), {
    y,
    font: "RobotoCondensed-Bold",
    size: 21,
    lineHeight: 28,
  });
}

function drawDivider(doc, y) {
  doc
    .save()
    .lineWidth(pt(2))
    .moveTo(pt(INVOICE_MARGIN_X), pt(y))
    .lineTo(pt(INVOICE_MARGIN_X + INVOICE_CONTENT_WIDTH), pt(y))
    .strokeColor("#000")
    .stroke()
    .restore();

  return y + 8;
}

function drawInvoiceRow(doc, left, right, y, options = {}) {
  const leftWidth = options.leftWidth ?? 460;
  const rightWidth = options.rightWidth ?? INVOICE_CONTENT_WIDTH - leftWidth;
  const size = options.size ?? 19;
  const lineHeight = options.lineHeight ?? 26;
  const font = options.font ?? "Roboto-Medium";
  const measuredHeight = measureText(doc, left, {
    font,
    size,
    lineHeight,
    width: leftWidth,
  });
  const rowHeight = Math.max(measuredHeight, lineHeight);

  doc
    .font(font)
    .fontSize(pt(size))
    .fillColor("#000")
    .text(left, pt(INVOICE_MARGIN_X), pt(y), {
      width: pt(leftWidth),
      lineGap: lineGap(doc, lineHeight),
      align: "left",
    });

  doc
    .font(font)
    .fontSize(pt(size))
    .fillColor("#000")
    .text(right, pt(INVOICE_MARGIN_X + leftWidth), pt(y), {
      width: pt(rightWidth),
      lineGap: lineGap(doc, lineHeight),
      align: "right",
    });

  return y + rowHeight + 6;
}

function drawFlowText(doc, value, options = {}) {
  const font = options.font ?? "Roboto-Medium";
  const size = options.size ?? 19;
  const lineHeight = options.lineHeight ?? 26;
  const x = options.x ?? INVOICE_MARGIN_X;
  const y = options.y ?? 0;
  const width = options.width ?? INVOICE_CONTENT_WIDTH;
  const text = asText(value);

  if (!text) {
    return y;
  }

  doc
    .font(font)
    .fontSize(pt(size))
    .fillColor("#000")
    .text(text, pt(x), pt(y), {
      width: pt(width),
      lineGap: lineGap(doc, lineHeight),
      align: options.align || "left",
    });

  return y + measureText(doc, text, { font, size, lineHeight, width }) + 6;
}

function measureText(doc, value, options) {
  doc.font(options.font).fontSize(pt(options.size));
  const heightPt = doc.heightOfString(String(value), {
    width: pt(options.width),
    lineGap: lineGap(doc, options.lineHeight),
  });

  return Math.ceil(heightPt / PX_TO_PT);
}

function registerFonts(doc) {
  doc.registerFont("Jost-ExtraBold", JOST_EXTRABOLD_PATH);
  doc.registerFont("Jost-Bold", JOST_BOLD_PATH);
  doc.registerFont("Jost-SemiBold", JOST_SEMIBOLD_PATH);
  doc.registerFont("Roboto-Medium", ROBOTO_MEDIUM_PATH);
  doc.registerFont("RobotoCondensed-Bold", ROBOTO_CONDENSED_BOLD_PATH);
}

function strokeRect(doc, x, y, width, height, strokeWidth) {
  doc
    .save()
    .lineWidth(pt(strokeWidth))
    .strokeColor("#000")
    .rect(pt(x), pt(y), pt(width), pt(height))
    .stroke()
    .restore();
}

function drawSingleLine(doc, text, options) {
  doc
    .font(options.font)
    .fontSize(pt(options.size))
    .fillColor("#000")
    .text(text, pt(options.x), pt(options.y), {
      width: pt(options.width),
      height: pt(options.height),
      lineGap: lineGap(doc, options.lineHeight),
      align: options.align || "left",
    });
}

function drawOrderId(doc, orderId) {
  const label = "ORDER ID:\u00a0";
  const number = `#${orderId}`;
  const x = pt(193);
  const y = pt(352);
  const width = pt(425);

  doc.font("Jost-Bold").fontSize(pt(40));
  const labelWidth = doc.widthOfString(label);
  doc.font("Jost-Bold").fontSize(pt(32));
  const numberWidth = doc.widthOfString(number);
  const startX = x + (width - labelWidth - numberWidth) / 2;

  doc
    .fillColor("#000")
    .font("Jost-Bold")
    .fontSize(pt(40))
    .text(label, startX, y, {
      lineGap: lineGap(doc, 58),
      continued: true,
    })
    .font("Jost-Bold")
    .fontSize(pt(32))
    .text(number, {
      lineGap: lineGap(doc, 46),
      continued: false,
    });
}

function drawLabelValue(doc, options) {
  const x = pt(options.x);
  const y = pt(options.y);
  const width = pt(options.width);
  const height = pt(options.height);
  const labelLineHeight = 33;
  const valueY = y + pt(labelLineHeight);

  doc
    .font("RobotoCondensed-Bold")
    .fontSize(pt(28))
    .fillColor("#000")
    .text(options.label, x, y, {
      width,
      height: pt(labelLineHeight),
      lineGap: lineGap(doc, labelLineHeight),
      align: "left",
    });

  doc
    .font("Roboto-Medium")
    .fontSize(pt(28))
    .fillColor("#000")
    .text(options.value, x, valueY, {
      width,
      height: Math.max(0, height - pt(labelLineHeight)),
      lineGap: lineGap(doc, 33),
      align: "left",
    });
}

function lineGap(doc, lineHeightPx) {
  return pt(lineHeightPx) - doc.currentLineHeight(false);
}

function normalizeLabelJob(job) {
  const orderId = asText(job.orderNumber || job.orderId || "ORDER");
  const shipTo = asText(job.customerName || "Bayblaze customer");
  const instructions = asText(job.instructions);
  const address = normalizeAddress(job.address).join("\n");

  return {
    orderId: stripLeadingHash(orderId),
    shipTo,
    instructions,
    address: address || "Address unavailable",
  };
}

function normalizeInvoiceJob(job) {
  const totals = job.totals && typeof job.totals === "object" ? job.totals : {};

  return {
    orderNumber: stripLeadingHash(asText(job.orderNumber || job.orderId || "ORDER")),
    customerName: asText(job.customerName || "BayBlaze customer"),
    customerPhone: asText(job.customerPhone),
    customerEmail: asText(job.customerEmail),
    address: normalizeAddress(job.address),
    currencyCode: asText(job.currencyCode || "USD").toUpperCase(),
    paymentMethod: asText(job.paymentMethod || "Pay on delivery"),
    items: Array.isArray(job.items)
      ? job.items.map((item) => ({
          title: asText(item.title || "Item"),
          variantTitle: asText(item.variantTitle),
          quantity: Number.isFinite(Number(item.quantity)) ? Number(item.quantity) : 0,
          unitPrice: moneyNumber(item.unitPrice),
          total: moneyNumber(item.total),
        }))
      : [],
    totals: {
      subtotal: moneyNumber(totals.subtotal),
      discountTotal: moneyNumber(totals.discountTotal),
      discountLabel: asText(totals.discountLabel || "Discount"),
      shippingTotal: moneyNumber(totals.shippingTotal),
      taxTotal: moneyNumber(totals.taxTotal),
      total: moneyNumber(totals.total),
    },
  };
}

function normalizeAddress(address) {
  if (Array.isArray(address)) {
    return address.map(asText).filter(Boolean);
  }

  if (typeof address === "string") {
    return address
      .split(/\r?\n/)
      .map(asText)
      .filter(Boolean);
  }

  return [];
}

function stripLeadingHash(value) {
  return value.replace(/^#+/, "");
}

function moneyNumber(value) {
  const numeric = Number(value);
  return Number.isFinite(numeric) ? numeric : 0;
}

function formatInvoiceMoney(value, currencyCode) {
  const numeric = Number(value || 0);
  const sign = numeric < 0 ? "-" : "";
  const amount = Math.abs(numeric) / 100;

  try {
    return `${sign}${new Intl.NumberFormat("en-US", {
      currency: currencyCode || "USD",
      style: "currency",
    }).format(amount)}`;
  } catch {
    return `${sign}$${amount.toFixed(2)}`;
  }
}

function formatInvoiceDate(date) {
  try {
    return new Intl.DateTimeFormat("en-US", {
      dateStyle: "short",
      timeStyle: "short",
    }).format(date);
  } catch {
    return date.toISOString();
  }
}

function asText(value) {
  return String(value ?? "").trim();
}

function pt(value) {
  return value * PX_TO_PT;
}

module.exports = {
  renderInvoicePdf,
  renderLabelPdf,
};
