// tools/generate_icons.js
// Generates Android launcher icons + Play Store icon from assets/logo/logo.png
// Uses the sharp library (Node.js) — no Python required

const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const logoPath = path.resolve('assets/logo/logo.png');
const outputBase = path.resolve('android/app/src/main/res');

// Android required sizes
const sizes = {
  'mipmap-mdpi':    48,
  'mipmap-hdpi':    72,
  'mipmap-xhdpi':   96,
  'mipmap-xxhdpi':  144,
  'mipmap-xxxhdpi': 192,
};

const BLUE = { r: 0, g: 117, b: 201, alpha: 1 };

async function generateIcon(size, outputPath) {
  const logoSize = Math.round(size * 0.8);
  const offset  = Math.floor((size - logoSize) / 2);

  // Resize logo, then composite onto solid blue background
  const resizedLogo = await sharp(logoPath)
    .resize(logoSize, logoSize, { fit: 'contain', background: BLUE })
    .toBuffer();

  await sharp({
    create: {
      width:      size,
      height:     size,
      channels:   4,
      background: BLUE,
    },
  })
    .composite([{ input: resizedLogo, top: offset, left: offset }])
    .png()
    .toFile(outputPath);

  console.log(`Generated: ${outputPath}  (${size}x${size}px)`);
}

async function main() {
  // Android launcher icons
  for (const [folder, size] of Object.entries(sizes)) {
    const dir = path.join(outputBase, folder);
    fs.mkdirSync(dir, { recursive: true });
    await generateIcon(size, path.join(dir, 'ic_launcher.png'));
  }

  // Play Store 512x512
  const playStorePath = path.resolve('assets/logo/play_store_icon.png');
  await generateIcon(512, playStorePath);
  console.log('\nDone! Play Store icon saved to assets/logo/play_store_icon.png');
}

main().catch(err => { console.error(err); process.exit(1); });
