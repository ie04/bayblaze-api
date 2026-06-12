const fs = require("node:fs");
const path = require("node:path");

const LABEL_FRAME_WIDTH_PX = 812;
const LABEL_FRAME_HEIGHT_PX = 1218;
const LABEL_WIDTH_IN = 4;
const LABEL_HEIGHT_IN = 6;
const CSS_DPI = 96;
const PRINT_SCALE = (LABEL_WIDTH_IN * CSS_DPI) / LABEL_FRAME_WIDTH_PX;
const BAYBLAZE_LOGO_PATH = path.resolve(
  __dirname,
  "..",
  "assets",
  "bayblaze-pixel-logo.png",
);
const JOST_EXTRABOLD_PATH = path.resolve(
  __dirname,
  "..",
  "assets",
  "fonts",
  "jost-extrabold.ttf",
);
const JOST_BOLD_PATH = path.resolve(
  __dirname,
  "..",
  "assets",
  "fonts",
  "jost-bold.ttf",
);
const JOST_SEMIBOLD_PATH = path.resolve(
  __dirname,
  "..",
  "assets",
  "fonts",
  "jost-semibold.ttf",
);
const ROBOTO_MEDIUM_PATH = path.resolve(
  __dirname,
  "..",
  "assets",
  "fonts",
  "roboto-medium.ttf",
);
const ROBOTO_CONDENSED_BOLD_PATH = path.resolve(
  __dirname,
  "..",
  "assets",
  "fonts",
  "roboto-condensed-bold.ttf",
);

function buildDeliveryLabelPreviewHtml(options = {}) {
  const logoDataUrl = fileDataUrl(BAYBLAZE_LOGO_PATH, "image/png");
  const jostExtraBoldDataUrl = fileDataUrl(JOST_EXTRABOLD_PATH, "font/ttf");
  const jostBoldDataUrl = fileDataUrl(JOST_BOLD_PATH, "font/ttf");
  const jostSemiBoldDataUrl = fileDataUrl(JOST_SEMIBOLD_PATH, "font/ttf");
  const robotoMediumDataUrl = fileDataUrl(ROBOTO_MEDIUM_PATH, "font/ttf");
  const robotoCondensedBoldDataUrl = fileDataUrl(
    ROBOTO_CONDENSED_BOLD_PATH,
    "font/ttf",
  );
  const orderId = templateText(options, "orderId", "{{order_id}}");
  const shipTo = templateText(options, "shipTo", "{{ship_to}}");
  const instructions = templateText(options, "instructions", "{{instructions}}");
  const address = templateText(options, "address", "{{address}}");

  return `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Bayblaze Delivery Label Template</title>
    <style>
      @font-face {
        font-family: "Jost";
        font-style: normal;
        font-weight: 800;
        src: url("${jostExtraBoldDataUrl}") format("truetype");
      }

      @font-face {
        font-family: "Jost";
        font-style: normal;
        font-weight: 700;
        src: url("${jostBoldDataUrl}") format("truetype");
      }

      @font-face {
        font-family: "Jost";
        font-style: normal;
        font-weight: 600;
        src: url("${jostSemiBoldDataUrl}") format("truetype");
      }

      @font-face {
        font-family: "Roboto";
        font-style: normal;
        font-weight: 500;
        src: url("${robotoMediumDataUrl}") format("truetype");
      }

      @font-face {
        font-family: "Roboto Condensed";
        font-style: normal;
        font-weight: 700;
        src: url("${robotoCondensedBoldDataUrl}") format("truetype");
      }

      @page {
        size: ${LABEL_WIDTH_IN}in ${LABEL_HEIGHT_IN}in;
        margin: 0;
      }

      :root {
        --label-frame-width: ${LABEL_FRAME_WIDTH_PX}px;
        --label-frame-height: ${LABEL_FRAME_HEIGHT_PX}px;
        --label-print-width: ${LABEL_WIDTH_IN}in;
        --label-print-height: ${LABEL_HEIGHT_IN}in;
        --label-print-scale: ${PRINT_SCALE};
      }

      * {
        box-sizing: border-box;
      }

      html,
      body {
        margin: 0;
        min-height: 100%;
      }

      body {
        align-items: center;
        background: #e9eaec;
        display: flex;
        justify-content: center;
        min-height: 100vh;
        padding: 24px;
      }

      .delivery-label-preview {
        height: var(--label-frame-height);
        overflow: hidden;
        width: var(--label-frame-width);
      }

      .delivery-label-frame {
        background: #ffffff;
        box-shadow: 0 18px 54px rgba(0, 0, 0, 0.18);
        color: #000000;
        font-family: Arial, Helvetica, sans-serif;
        height: var(--label-frame-height);
        overflow: hidden;
        position: relative;
        transform-origin: top left;
        width: var(--label-frame-width);
      }

      .label-layer {
        position: absolute;
      }

      .label-frame-layer {
        inset: 0;
      }

      .label-border {
        border: 3px solid #000000;
        height: 1138px;
        left: 40px;
        top: 40px;
        width: 732px;
      }

      .qr-code-placeholder {
        border: 3px solid #000000;
        height: 320px;
        left: 420px;
        top: 825px;
        width: 320px;
      }

      .order-id-rect {
        border: 3px solid #000000;
        height: 81px;
        left: 40px;
        top: 340px;
        width: 732px;
      }

      .bayblaze-logo {
        height: 203px;
        image-rendering: pixelated;
        left: 192px;
        object-fit: fill;
        top: 50px;
        width: 427px;
      }

      .delivery-label-title {
        color: #000000;
        font-family: Jost, Arial, Helvetica, sans-serif;
        font-size: 48px;
        font-weight: 800;
        height: 68px;
        left: 201px;
        letter-spacing: 0;
        line-height: 69px;
        top: 260px;
        white-space: nowrap;
        width: 409px;
      }

      .order-id-value {
        align-items: center;
        color: #000000;
        display: flex;
        font-family: Jost, Arial, Helvetica, sans-serif;
        font-weight: 700;
        height: 57px;
        justify-content: center;
        left: 193px;
        letter-spacing: 0;
        text-align: center;
        top: 352px;
        white-space: nowrap;
        width: 425px;
      }

      .order-id-label {
        font-size: 40px;
        line-height: 58px;
      }

      .order-id-number {
        font-size: 32px;
        line-height: 46px;
      }

      .ship-to-value {
        color: #000000;
        height: 219px;
        left: 56px;
        letter-spacing: 0;
        overflow: hidden;
        text-align: left;
        top: 449px;
        width: 339px;
      }

      .ship-to-label {
        display: block;
        font-family: "Roboto Condensed", Arial, Helvetica, sans-serif;
        font-size: 28px;
        font-weight: 700;
        line-height: 33px;
      }

      .ship-to-name {
        display: block;
        font-family: Roboto, Arial, Helvetica, sans-serif;
        font-size: 28px;
        font-weight: 500;
        line-height: 33px;
      }

      .instructions-value {
        color: #000000;
        height: 335px;
        left: 406px;
        letter-spacing: 0;
        overflow: hidden;
        text-align: left;
        top: 448px;
        width: 340px;
      }

      .instructions-label {
        display: block;
        font-family: "Roboto Condensed", Arial, Helvetica, sans-serif;
        font-size: 28px;
        font-weight: 700;
        line-height: 33px;
      }

      .instructions-text {
        display: block;
        font-family: Roboto, Arial, Helvetica, sans-serif;
        font-size: 28px;
        font-weight: 500;
        line-height: 33px;
      }

      .address-value {
        color: #000000;
        height: 510px;
        left: 56px;
        letter-spacing: 0;
        overflow: hidden;
        text-align: left;
        top: 668px;
        width: 350px;
      }

      .address-label {
        display: block;
        font-family: "Roboto Condensed", Arial, Helvetica, sans-serif;
        font-size: 28px;
        font-weight: 700;
        line-height: 33px;
      }

      .address-text {
        display: block;
        font-family: Roboto, Arial, Helvetica, sans-serif;
        font-size: 28px;
        font-weight: 500;
        line-height: 33px;
        white-space: pre-line;
      }

      .scan-instructions {
        color: #000000;
        font-family: Jost, Arial, Helvetica, sans-serif;
        font-size: 20px;
        font-weight: 600;
        height: 29px;
        left: 411px;
        letter-spacing: 0;
        line-height: 29px;
        text-align: left;
        top: 796px;
        white-space: nowrap;
        width: 338px;
      }

      @media print {
        html,
        body {
          background: #ffffff;
          height: var(--label-print-height);
          min-height: 0;
          padding: 0;
          width: var(--label-print-width);
        }

        .delivery-label-preview {
          height: var(--label-print-height);
          width: var(--label-print-width);
        }

        .delivery-label-frame {
          box-shadow: none;
          transform: scale(var(--label-print-scale));
        }
      }
    </style>
  </head>
  <body>
    <div class="delivery-label-preview">
      <main
        class="delivery-label-frame"
        aria-label="Bayblaze 4 by 6 inch delivery label"
        data-figma-frame-width="${LABEL_FRAME_WIDTH_PX}"
        data-figma-frame-height="${LABEL_FRAME_HEIGHT_PX}"
      >
        <div class="label-layer label-frame-layer" data-layer="Frame"></div>
        <div class="label-layer label-border" data-layer="rect.labelBorder"></div>
        <div class="label-layer qr-code-placeholder" data-layer="placeholder.qrCode"></div>
        <div class="label-layer order-id-rect" data-layer="rect.orderIdRect"></div>
        <img
          class="label-layer bayblaze-logo"
          data-layer="image.bayblazeLogo"
          src="${logoDataUrl}"
          alt="Bayblaze"
        >
        <div class="label-layer delivery-label-title" data-layer="title.deliveryLabel">DELIVERY LABEL</div>
        <div class="label-layer order-id-value" data-layer="value.orderId">
          <span class="order-id-label">ORDER ID:&nbsp;</span>
          <span class="order-id-number">#${escapeHtml(orderId)}</span>
        </div>
        <div class="label-layer ship-to-value" data-layer="value.shipTo">
          <span class="ship-to-label">SHIP TO:</span>
          <span class="ship-to-name">${escapeHtml(shipTo)}</span>
        </div>
        <div class="label-layer instructions-value" data-layer="value.instructions">
          <span class="instructions-label">INSTRUCTIONS:</span>
          <span class="instructions-text">${escapeHtml(instructions)}</span>
        </div>
        <div class="label-layer address-value" data-layer="value.address">
          <span class="address-label">ADDRESS:</span>
          <span class="address-text">${escapeHtml(address)}</span>
        </div>
        <div class="label-layer scan-instructions" data-layer="text.scanInstructions">SCAN QR TO VIEW ORDER DETAILS</div>
      </main>
    </div>
  </body>
</html>`;
}

function fileDataUrl(filePath, mimeType) {
  const buffer = fs.readFileSync(filePath);

  return `data:${mimeType};base64,${buffer.toString("base64")}`;
}

function asText(value) {
  return String(value ?? "").trim();
}

function templateText(options, key, fallback) {
  return Object.hasOwn(options, key) ? asText(options[key]) : fallback;
}

function escapeHtml(value) {
  return asText(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

module.exports = {
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
  buildDeliveryLabelPreviewHtml,
};
