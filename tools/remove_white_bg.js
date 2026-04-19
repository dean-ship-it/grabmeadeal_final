// tools/remove_white_bg.js
// Reads each PNG in assets/category_icons/ and converts near-white pixels to transparent.
// Uses a tolerance threshold + edge feathering to avoid hard edges.
//
// Usage: node tools/remove_white_bg.js

const { Jimp } = require("jimp");
const fs = require("fs");
const path = require("path");

const ICONS_DIR = path.join(__dirname, "..", "assets", "category_icons");

// Pixels with all RGB channels >= WHITE_THRESHOLD become fully transparent.
// Pixels between FEATHER_START..WHITE_THRESHOLD get partial transparency for soft edges.
const WHITE_THRESHOLD = 240;
const FEATHER_START = 215;

async function processIcon(filePath) {
  const img = await Jimp.read(filePath);
  let removed = 0;
  let feathered = 0;

  img.scan(0, 0, img.bitmap.width, img.bitmap.height, function (x, y, idx) {
    const r = this.bitmap.data[idx];
    const g = this.bitmap.data[idx + 1];
    const b = this.bitmap.data[idx + 2];
    const minChannel = Math.min(r, g, b);

    if (minChannel >= WHITE_THRESHOLD) {
      // Fully transparent
      this.bitmap.data[idx + 3] = 0;
      removed++;
    } else if (minChannel >= FEATHER_START) {
      // Soft edge — scale alpha based on how close to white
      const t = (minChannel - FEATHER_START) / (WHITE_THRESHOLD - FEATHER_START);
      const currentAlpha = this.bitmap.data[idx + 3];
      this.bitmap.data[idx + 3] = Math.round(currentAlpha * (1 - t));
      feathered++;
    }
  });

  await img.write(filePath);
  return { removed, feathered };
}

(async () => {
  const files = fs
    .readdirSync(ICONS_DIR)
    .filter((f) => f.toLowerCase().endsWith(".png"));

  console.log(`Processing ${files.length} PNG(s) in ${ICONS_DIR}\n`);

  for (const file of files) {
    const filePath = path.join(ICONS_DIR, file);
    try {
      const { removed, feathered } = await processIcon(filePath);
      const total = removed + feathered;
      const pct = total > 0 ? ` (${removed} cleared, ${feathered} feathered)` : "";
      console.log(`  ✓ ${file}${pct}`);
    } catch (err) {
      console.error(`  ✗ ${file}: ${err.message}`);
    }
  }

  console.log("\nDone.");
})();
