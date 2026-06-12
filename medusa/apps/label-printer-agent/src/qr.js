const path = require("node:path");
const QRCode = require("qrcode");
const sharp = require("sharp");

const QR_DARK_COLOR = "#000000";
const QR_LIGHT_COLOR = "#ffffff";
const QR_IMAGE_SIZE = 1200;
const CENTER_LOGO_MAX_SIZE = 330;

function createRoundedRectSvg(width, height, radius, fill) {
  return Buffer.from(`
    <svg width="${width}" height="${height}" viewBox="0 0 ${width} ${height}" xmlns="http://www.w3.org/2000/svg">
      <rect x="0" y="0" width="${width}" height="${height}" rx="${radius}" ry="${radius}" fill="${fill}"/>
    </svg>
  `);
}

async function buildCenteredLogoBuffer(input, options = {}) {
  const { horizontalPadding = 12, roundedRadiusRatio = 0 } = options;
  const logoMetadata = await sharp(input).metadata();
  const logoAspectWidth = logoMetadata.width || CENTER_LOGO_MAX_SIZE;
  const logoAspectHeight = logoMetadata.height || CENTER_LOGO_MAX_SIZE;
  const logoScale = Math.min(
    CENTER_LOGO_MAX_SIZE / logoAspectWidth,
    CENTER_LOGO_MAX_SIZE / logoAspectHeight,
  );
  const logoWidth = Math.round(logoAspectWidth * logoScale);
  const logoHeight = Math.round(logoAspectHeight * logoScale);

  const logoMaskBuffer = await sharp(input)
    .resize(logoWidth, logoHeight, {
      fit: "contain",
      position: "centre",
      background: QR_LIGHT_COLOR,
    })
    .greyscale()
    .threshold(200)
    .negate()
    .png()
    .toBuffer();

  const logoForegroundBuffer = await sharp({
    create: {
      width: logoWidth,
      height: logoHeight,
      channels: 3,
      background: QR_DARK_COLOR,
    },
  })
    .joinChannel(logoMaskBuffer)
    .png()
    .toBuffer();

  const canvasWidth = logoWidth + horizontalPadding * 2;
  const canvasHeight = logoHeight;
  const backgroundBuffer =
    roundedRadiusRatio > 0
      ? await sharp(
          createRoundedRectSvg(
            canvasWidth,
            canvasHeight,
            Math.round(Math.min(canvasWidth, canvasHeight) * roundedRadiusRatio),
            QR_LIGHT_COLOR,
          ),
        )
          .png()
          .toBuffer()
      : await sharp({
          create: {
            width: canvasWidth,
            height: canvasHeight,
            channels: 3,
            background: QR_LIGHT_COLOR,
          },
        })
          .png()
          .toBuffer();

  return sharp(backgroundBuffer)
    .composite([
      {
        input: logoForegroundBuffer,
        left: horizontalPadding,
        top: 0,
      },
    ])
    .png()
    .toBuffer();
}

async function buildStyledQrBuffer(targetUrl, centeredLogoInput) {
  const qrBuffer = await QRCode.toBuffer(targetUrl, {
    errorCorrectionLevel: "H",
    type: "png",
    width: QR_IMAGE_SIZE,
    margin: 0,
    color: {
      dark: QR_DARK_COLOR,
      light: QR_LIGHT_COLOR,
    },
  });

  const logoBuffer = await buildCenteredLogoBuffer(centeredLogoInput, {
    horizontalPadding: 12,
  });

  return sharp(qrBuffer)
    .composite([
      {
        input: logoBuffer,
        gravity: "center",
      },
    ])
    .png()
    .toBuffer();
}

function defaultQrLogoPath() {
  return path.join(__dirname, "..", "assets", "bayblaze-flame-qr.png");
}

module.exports = {
  buildStyledQrBuffer,
  defaultQrLogoPath,
};
