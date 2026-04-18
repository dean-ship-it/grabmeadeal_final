// Test CJ Affiliate API connectivity — zero dependencies
const fs = require("fs");
const path = require("path");
const https = require("https");

// Read .env
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

if (!CJ_API_KEY || CJ_API_KEY === "your_cj_api_key_here") {
  console.log("\n❌ CJ API key not configured.");
  process.exit(0);
}

// Test 1: REST Advertiser Lookup API
console.log("\n--- Test 1: REST Advertiser Lookup API ---");
const restUrl = `https://advertiser-lookup.api.cj.com/v2/advertiser-lookup?requestor-cid=${CJ_WEBSITE_ID}&records-per-page=5&advertiser-ids=joined`;
const req1 = https.get(restUrl, { headers: { Authorization: `Bearer ${CJ_API_KEY}` }, timeout: 10000 }, res => {
  let data = "";
  res.on("data", chunk => data += chunk);
  res.on("end", () => {
    console.log(`Status: ${res.statusCode}`);
    if (res.statusCode === 200) {
      console.log("✅ Advertiser Lookup API connected!");
      console.log(data.substring(0, 500));
    } else {
      console.log(`Response: ${data.substring(0, 300)}`);
    }

    // Test 2: GraphQL Product Feed API
    console.log("\n--- Test 2: GraphQL Product Feed API ---");
    const query = JSON.stringify({
      query: `{ products(companyId: "${CJ_WEBSITE_ID}", limit: 3) { totalCount resultList { title salePrice { amount currency } price { amount currency } advertiserName link imageLink } } }`
    });
    const options = {
      hostname: "ads.api.cj.com",
      path: "/query",
      method: "POST",
      headers: {
        "Authorization": `Bearer ${CJ_API_KEY}`,
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(query),
      },
      timeout: 10000,
    };
    const req2 = https.request(options, res2 => {
      let data2 = "";
      res2.on("data", chunk => data2 += chunk);
      res2.on("end", () => {
        console.log(`Status: ${res2.statusCode}`);
        if (res2.statusCode === 200) {
          console.log("✅ Product Feed GraphQL API connected!");
          try {
            const parsed = JSON.parse(data2);
            const total = parsed.data?.products?.totalCount || 0;
            console.log(`Total products available: ${total}`);
            const products = parsed.data?.products?.resultList || [];
            products.forEach(p => console.log(`  - ${p.title} ($${p.salePrice}) — ${p.advertiserName}`));
          } catch (e) {
            console.log(data2.substring(0, 500));
          }
        } else {
          console.log(`Response: ${data2.substring(0, 300)}`);
        }
        process.exit(0);
      });
    });
    req2.on("error", err => { console.error(`Connection failed: ${err.message}`); process.exit(1); });
    req2.write(query);
    req2.end();
  });
});
req1.on("error", err => { console.error(`Connection failed: ${err.message}`); process.exit(1); });
