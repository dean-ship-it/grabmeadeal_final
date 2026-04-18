// functions/scrapers/cj_scraper.js
// Commission Junction GraphQL Product Feed scraper
// Uses the CJ Ads GraphQL API (ads.api.cj.com/query)

const https = require("https");
const path = require("path");
const fs = require("fs");

// Load .env manually (no dotenv dependency needed)
const envPath = path.resolve(__dirname, "../.env");
if (fs.existsSync(envPath)) {
  fs.readFileSync(envPath, "utf8").split("\n").forEach(line => {
    const eq = line.indexOf("=");
    if (eq > 0 && !line.trim().startsWith("#")) {
      const key = line.substring(0, eq).trim();
      const val = line.substring(eq + 1).trim();
      if (!process.env[key]) process.env[key] = val;
    }
  });
}

const CJ_API_KEY = process.env.CJ_API_KEY;
const CJ_CID = process.env.CJ_WEBSITE_ID; // Company ID

// Category mapping from CJ product categories to our DealCategory enum
const CATEGORY_MAP = {
  "electronics": "electronics",
  "computers": "electronics",
  "computer": "electronics",
  "laptop": "electronics",
  "phone": "electronics",
  "audio": "electronics",
  "camera": "electronics",
  "tv": "electronics",
  "tablet": "electronics",
  "appliance": "homeGoods",
  "kitchen": "homeGoods",
  "home": "homeGoods",
  "house": "homeGoods",
  "garden": "homeGoods",
  "cleaning": "homeGoods",
  "clothing": "apparel",
  "apparel": "apparel",
  "shoes": "apparel",
  "fashion": "apparel",
  "shirt": "apparel",
  "dress": "apparel",
  "jacket": "apparel",
  "tools": "tools",
  "hardware": "tools",
  "power tool": "tools",
  "automotive": "automotive",
  "car": "automotive",
  "truck": "automotive",
  "vehicle": "automotive",
  "auto parts": "automotive",
  "grocery": "grocery",
  "food": "grocery",
  "snack": "grocery",
  "beverage": "grocery",
  "coffee": "grocery",
  "beauty": "beauty",
  "cosmetic": "beauty",
  "skincare": "beauty",
  "makeup": "beauty",
  "hair": "beauty",
  "fragrance": "beauty",
  "toy": "gaming",
  "game": "gaming",
  "gaming": "gaming",
  "video game": "gaming",
  "console": "gaming",
  "furniture": "furniture",
  "sofa": "furniture",
  "desk": "furniture",
  "chair": "furniture",
  "table": "furniture",
  "bed": "furniture",
  "mattress": "furniture",
  "fitness": "fitness",
  "exercise": "fitness",
  "workout": "fitness",
  "gym": "fitness",
  "sport": "fitness",
  "yoga": "fitness",
  "pet": "petSupplies",
  "dog": "petSupplies",
  "cat": "petSupplies",
  "animal": "petSupplies",
};

function mapCategory(title, category) {
  const text = `${title} ${category}`.toLowerCase();
  for (const [key, val] of Object.entries(CATEGORY_MAP)) {
    if (text.includes(key)) return val;
  }
  return "homeGoods";
}

function graphqlRequest(query) {
  return new Promise((resolve, reject) => {
    const body = JSON.stringify({ query });
    const options = {
      hostname: "ads.api.cj.com",
      path: "/query",
      method: "POST",
      headers: {
        "Authorization": `Bearer ${CJ_API_KEY}`,
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(body),
      },
      timeout: 30000,
    };
    const req = https.request(options, res => {
      let data = "";
      res.on("data", chunk => data += chunk);
      res.on("end", () => {
        if (res.statusCode !== 200) {
          reject(new Error(`CJ API ${res.statusCode}: ${data.substring(0, 300)}`));
          return;
        }
        try { resolve(JSON.parse(data)); }
        catch (e) { reject(new Error(`JSON parse error: ${data.substring(0, 200)}`)); }
      });
    });
    req.on("error", reject);
    req.on("timeout", () => { req.destroy(); reject(new Error("timeout")); });
    req.write(body);
    req.end();
  });
}

// Search terms targeting our deal categories
const SEARCH_QUERIES = [
  { keywords: "electronics deal sale TV laptop", category: "electronics" },
  { keywords: "beauty skincare cosmetics sale", category: "beauty" },
  { keywords: "apparel clothing shoes sale", category: "apparel" },
  { keywords: "tools hardware power tool sale", category: "tools" },
  { keywords: "automotive car accessories sale", category: "automotive" },
  { keywords: "furniture sofa desk chair sale", category: "furniture" },
  { keywords: "fitness exercise gym equipment", category: "fitness" },
  { keywords: "pet dog cat supplies sale", category: "petSupplies" },
  { keywords: "gaming video game console", category: "gaming" },
  { keywords: "grocery food coffee snack", category: "grocery" },
  { keywords: "home kitchen appliance garden", category: "homeGoods" },
];

async function fetchCJDeals(limit = 50) {
  if (!CJ_API_KEY) {
    console.log("[CJ] API key not configured — skipping");
    return [];
  }

  const allDeals = [];
  const perQuery = Math.ceil(limit / SEARCH_QUERIES.length);

  for (const sq of SEARCH_QUERIES) {
    try {
      console.log(`[CJ] Searching: ${sq.keywords}...`);
      const query = `{
        products(
          companyId: "${CJ_CID}",
          limit: ${perQuery},
          keywords: "${sq.keywords}",
          currency: "USD"
        ) {
          totalCount
          resultList {
            title
            description
            salePrice { amount currency }
            price { amount currency }
            advertiserName
            link
            imageLink
            adId
          }
        }
      }`;

      const result = await graphqlRequest(query);
      const products = result.data?.products?.resultList || [];
      console.log(`[CJ]   Found ${products.length} products (${result.data?.products?.totalCount || 0} total)`);

      for (const p of products) {
        const salePrice = p.salePrice?.amount ? parseFloat(p.salePrice.amount) : null;
        const regularPrice = p.price?.amount ? parseFloat(p.price.amount) : null;
        const currentPrice = salePrice || regularPrice || 0;

        // Skip deals with no price or no title
        if (!currentPrice || !p.title) continue;
        // Skip if sale price >= regular price (not a deal)
        if (salePrice && regularPrice && salePrice >= regularPrice) continue;

        allDeals.push({
          title: p.title.substring(0, 120),
          description: (p.description || "").substring(0, 500),
          priceCurrent: currentPrice,
          priceWas: regularPrice || null,
          price: currentPrice,
          originalPrice: regularPrice || null,
          vendor: p.advertiserName || "",
          link: p.link || "",
          imageUrl: p.imageLink || "",
          category: mapCategory(p.title, sq.category),
          source: "cj",
          cjAdId: p.adId || "",
          createdAt: new Date().toISOString(),
        });
      }

      // Small delay between requests to be respectful
      await new Promise(r => setTimeout(r, 300));
    } catch (err) {
      console.error(`[CJ] Error searching "${sq.keywords}": ${err.message}`);
    }
  }

  // Deduplicate by title
  const seen = new Set();
  const unique = allDeals.filter(d => {
    const key = d.title.toLowerCase().trim();
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });

  console.log(`[CJ] Total unique deals: ${unique.length}`);
  return unique;
}

async function syncCJDealsToFirestore(limit = 50) {
  // Firebase init — use service account key when running standalone
  let db;
  const admin = require("firebase-admin");
  if (!admin.apps.length) {
    const saPath = path.resolve(__dirname, "../../serviceAccountKey.json");
    if (fs.existsSync(saPath)) {
      admin.initializeApp({
        credential: admin.credential.cert(require(saPath)),
        projectId: "grab-me-a-deal-e69ae",
      });
    } else {
      admin.initializeApp({ projectId: "grab-me-a-deal-e69ae" });
    }
  }
  db = admin.firestore();

  const deals = await fetchCJDeals(limit);
  if (deals.length === 0) {
    console.log("[CJ] No deals to sync");
    return 0;
  }

  // Batch write (Firestore limit: 500 per batch)
  let count = 0;
  const batchSize = 450;
  for (let i = 0; i < deals.length; i += batchSize) {
    const batch = db.batch();
    const chunk = deals.slice(i, i + batchSize);
    for (const deal of chunk) {
      const ref = db.collection("deals").doc();
      batch.set(ref, deal);
      count++;
    }
    await batch.commit();
    console.log(`[CJ] Committed batch ${Math.floor(i / batchSize) + 1} (${chunk.length} deals)`);
  }

  console.log(`[CJ] ✅ Synced ${count} deals to Firestore`);
  return count;
}

module.exports = { syncCJDealsToFirestore, fetchCJDeals };

// Run standalone: node functions/scrapers/cj_scraper.js [limit]
if (require.main === module) {
  const limit = parseInt(process.argv[2]) || 50;
  console.log(`\n🔄 CJ Scraper — fetching up to ${limit} deals...\n`);
  syncCJDealsToFirestore(limit)
    .then(count => {
      console.log(`\n✅ Done! ${count} deals synced to Firestore.`);
      process.exit(0);
    })
    .catch(err => {
      console.error("Fatal error:", err);
      process.exit(1);
    });
}
