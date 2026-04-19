// tools/crop_category_icons.js
// Crops transparent margins from each category icon PNG so the artwork
// fills the canvas. Combined with a small in-code Padding inside each tile,
// this makes the icons render visibly larger without changing tile size.
//
// Run after remove_white_bg.js (which cleared the white backgrounds).
//
// Usage: node tools/crop_category_icons.js

const { Jimp } = require("jimp");
const fs = require("fs");
const path = require("path");

const ICONS_DIR = path.join(__dirname, "..", "assets", "category_icons");
const ALPHA_THRESHOLD = 32;

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

async function processIcon(filePath) {
  const img = await Jimp.read(filePath);
  const W = img.bitmap.width, H = img.bitmap.height;
  const b = findContentBounds(img, ALPHA_THRESHOLD);
  if (!b) return { skipped: true, reason: "no content" };

  // Crop to content
  const cropped = img.clone().crop(b);
  // Pad to square (transparent) so aspect ratio stays 1:1 — important for
  // BoxFit.contain to render consistently across mixed-aspect icons.
  const side = Math.max(cropped.bitmap.width, cropped.bitmap.height);
  const square = new Jimp({ width: side, height: side, color: 0x00000000 });
  const ox = Math.round((side - cropped.bitmap.width) / 2);
  const oy = Math.round((side - cropped.bitmap.height) / 2);
  square.composite(cropped, ox, oy);

  await square.write(filePath);
  const fillBefore = ((Math.max(b.w, b.h) / Math.min(W, H)) * 100).toFixed(0);
  return { skipped: false, before: `${W}x${H}`, after: `${side}x${side}`, fillBefore };
}

(async () => {
  const files = fs.readdirSync(ICONS_DIR).filter(f => f.toLowerCase().endsWith(".png"));
  console.log(`Cropping ${files.length} PNG(s) in ${ICONS_DIR}\n`);
  for (const f of files) {
    const fp = path.join(ICONS_DIR, f);
    try {
      const r = await processIcon(fp);
      if (r.skipped) console.log(`  ⚠ ${f}: ${r.reason}`);
      else console.log(`  ✓ ${f}: ${r.before} → ${r.after} (was ${r.fillBefore}% filled)`);
    } catch (err) {
      console.error(`  ✗ ${f}: ${err.message}`);
    }
  }
  console.log("\nDone.");
})();
