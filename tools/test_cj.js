// Test CJ Affiliate API connectivity — zero dependencies
const fs = require("fs");
const path = require("path");
const https = require("https");

// Try to read .env
const envPath = path.resolve(__dirname, "../functions/.env");
let CJ_API_KEY, CJ_WEBSITE_ID;
if (fs.existsSync(envPath)) {
  fs.readFileSync(envPath, "utf8").split("\n").forEach(line => {
    const [k, ...v] = line.split("=");
    if (k.trim() === "CJ_API_KEY") CJ_API_KEY = v.join("=").trim();
    if (k.trim() === "CJ_WEBSITE_ID") CJ_WEBSITE_ID = v.join("=").trim();
  });
}

console.log("=== CJ Affiliate API Test ===");
console.log(`CJ_API_KEY: ${CJ_API_KEY ? CJ_API_KEY.substring(0, 8) + "..." : "NOT SET"}`);
console.log(`CJ_WEBSITE_ID: ${CJ_WEBSITE_ID || "NOT SET"}`);
console.log(`.env file: ${fs.existsSync(envPath) ? "found" : "NOT FOUND"}`);

if (!CJ_API_KEY || CJ_API_KEY === "your_cj_api_key_here") {
  console.log("\n❌ CJ API key not configured.");
  console.log("\nTo activate the CJ scraper:");
  console.log("1. Sign up at https://www.cj.com (free for publishers)");
  console.log("2. Get your API key from Account → API Keys");
  console.log("3. Get your Website ID from Account → Websites");
  console.log("4. Create functions/.env (copy from functions/.env.example) with:");
  console.log("   CJ_API_KEY=<your_personal_access_token>");
  console.log("   CJ_WEBSITE_ID=<your_website_id>");
  console.log("\nThe scraper at functions/scrapers/cj_scraper.js is ready — just add credentials.");
  process.exit(0);
}

const url = `https://product-search.api.cj.com/v2/product-search?website-id=${CJ_WEBSITE_ID}&keywords=deal&records-per-page=1`;
const req = https.get(url, { headers: { Authorization: `Bearer ${CJ_API_KEY}` }, timeout: 10000 }, res => {
  let data = "";
  res.on("data", chunk => data += chunk);
  res.on("end", () => {
    if (res.statusCode === 200) {
      console.log(`\n✅ CJ API connected! Status: ${res.statusCode}`);
    } else if (res.statusCode === 401) {
      console.log(`\n❌ CJ API returned 401 — API key is invalid or expired`);
    } else if (res.statusCode === 403) {
      console.log(`\n❌ CJ API returned 403 — key lacks permission or website ID is wrong`);
    } else {
      console.log(`\n❌ CJ API returned ${res.statusCode}`);
    }
    process.exit(0);
  });
});
req.on("error", err => { console.error(`\n❌ Connection failed: ${err.message}`); process.exit(1); });
req.on("timeout", () => { req.destroy(); console.error("\n❌ Request timed out"); process.exit(1); });
