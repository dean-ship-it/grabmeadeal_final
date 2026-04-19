// tools/generate_launcher_from.js
// Generates Android launcher icons from a source PNG.
//
// - Crops transparent margins (icon has its own frame, no need for safe-zone padding)
// - Generates legacy ic_launcher.png at 5 DPIs
// - Generates adaptive ic_launcher_foreground.png at 5 DPIs (icon at ~92% of canvas
//   to leave small safety margin for circular launcher masks)
//
// Usage: node tools/generate_launcher_from.js <source.png>

const { Jimp } = require("jimp");
const fs = require("fs");
const path = require("path");

const SRC = process.argv[2] || path.join(__dirname, "..", "assets", "logo", "launcher_v2.png");
const RES_DIR = path.join(__dirname, "..", "android", "app", "src", "main", "res");

// alpha threshold — pixels above this count as content
const ALPHA_THRESHOLD = 32;
// adaptive foreground: how much of canvas the icon fills (rest is transparent margin)
const ADAPTIVE_FILL = 0.92;

// Standard Android launcher icon sizes (per dpi bucket)
const LEGACY_SIZES = {
  "mipmap-mdpi":    48,
  "mipmap-hdpi":    72,
  "mipmap-xhdpi":   96,
  "mipmap-xxhdpi":  144,
  "mipmap-xxxhdpi": 192,
};

// Adaptive foreground sizes (108dp base × dpi multiplier)
const ADAPTIVE_SIZES = {
  "drawable-mdpi":    108,
  "drawable-hdpi":    162,
  "drawable-xhdpi":   216,
  "drawable-xxhdpi":  324,
  "drawable-xxxhdpi": 432,
};

function findContentBounds(img, threshold) {
  const { width, height, data } = img.bitmap;
  let minX = width, minY = height, maxX = -1, maxY = -1;
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const a = data[(y * width + x) * 4 + 3];
      if (a > threshold) {
        if (x < minX) minX = x;
        if (y < minY) minY = y;
        if (x > maxX) maxX = x;
        if (y > maxY) maxY = y;
      }
    }
  }
  if (maxX < 0) return null;
  return { x: minX, y: minY, w: maxX - minX + 1, h: maxY - minY + 1 };
}

async function makeSquareCropped(srcPath) {
  const img = await Jimp.read(srcPath);
  const bounds = findContentBounds(img, ALPHA_THRESHOLD);
  if (!bounds) throw new Error("No opaque content found in source");

  // Crop to content
  const cropped = img.clone().crop(bounds);

  // Square-pad (transparent) so icon stays centered
  const side = Math.max(cropped.bitmap.width, cropped.bitmap.height);
  const square = new Jimp({ width: side, height: side, color: 0x00000000 });
  const ox = Math.round((side - cropped.bitmap.width) / 2);
  const oy = Math.round((side - cropped.bitmap.height) / 2);
  square.composite(cropped, ox, oy);
  return square;
}

async function main() {
  if (!fs.existsSync(SRC)) {
    console.error(`Source not found: ${SRC}`);
    process.exit(1);
  }
  console.log(`Source: ${SRC}`);
  const square = await makeSquareCropped(SRC);
  console.log(`Cropped + squared: ${square.bitmap.width}x${square.bitmap.height}\n`);

  console.log("Legacy ic_launcher.png:");
  for (const [dir, size] of Object.entries(LEGACY_SIZES)) {
    const out = path.join(RES_DIR, dir, "ic_launcher.png");
    if (!fs.existsSync(path.dirname(out))) {
      console.log(`  ⚠ ${dir}: directory missing, skipped`);
      continue;
    }
    const resized = square.clone().resize({ w: size, h: size });
    await resized.write(out);
    console.log(`  ✓ ${dir}/ic_launcher.png (${size}x${size})`);
  }

  console.log("\nAdaptive ic_launcher_foreground.png:");
  for (const [dir, size] of Object.entries(ADAPTIVE_SIZES)) {
    const out = path.join(RES_DIR, dir, "ic_launcher_foreground.png");
    if (!fs.existsSync(path.dirname(out))) {
      fs.mkdirSync(path.dirname(out), { recursive: true });
    }
    const inner = Math.round(size * ADAPTIVE_FILL);
    const canvas = new Jimp({ width: size, height: size, color: 0x00000000 });
    const resized = square.clone().resize({ w: inner, h: inner });
    const off = Math.round((size - inner) / 2);
    canvas.composite(resized, off, off);
    await canvas.write(out);
    console.log(`  ✓ ${dir}/ic_launcher_foreground.png (${size}x${size}, icon at ${inner}px = ${(ADAPTIVE_FILL * 100).toFixed(0)}%)`);
  }

  console.log("\nDone.");
}

main().catch((err) => {
  console.error("ERROR:", err.message);
  process.exit(1);
});
