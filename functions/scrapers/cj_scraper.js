// functions/scrapers/cj_scraper.js
// Commission Junction Affiliate API scraper
// Sign up free at cj.com to get API credentials

require("dotenv").config({ path: "../.env" });
const axios = require("axios");
const { db } = require("../firebase_init");

const CJ_API_KEY = process.env.CJ_API_KEY;
const CJ_WEBSITE_ID = process.env.CJ_WEBSITE_ID;

// Category mapping from CJ to our DealCategory enum
const CATEGORY_MAP = {
  "electronics": "electronics",
  "computers": "electronics",
  "appliances": "homeGoods",
  "clothing": "apparel",
  "apparel": "apparel",
  "tools": "tools",
  "automotive": "automotive",
  "grocery": "grocery",
  "beauty": "beauty",
  "toys": "toys",
  "gaming": "gaming",
  "furniture": "furniture",
  "fitness": "fitness",
  "pet": "petSupplies",
  "outdoor": "outdoor",
  "art": "art",
  "business": "business",
};

function mapCategory(cjCategory) {
  if (!cjCategory) return "homeGoods";
  const lower = cjCategory.toLowerCase();
  for (const [key, val] of Object.entries(CATEGORY_MAP)) {
    if (lower.includes(key)) return val;
  }
  return "homeGoods";
}

async function fetchCJDeals() {
  if (!CJ_API_KEY || CJ_API_KEY === "your_cj_api_key_here") {
    console.log("[CJ] API key not configured — skipping");
    return [];
  }

  try {
    console.log("[CJ] Fetching deals...");
    const response = await axios.get(
      "https://product-search.api.cj.com/v2/product-search",
      {
        headers: {
          Authorization: `Bearer ${CJ_API_KEY}`,
        },
        params: {
          "website-id": CJ_WEBSITE_ID,
          keywords: "deal sale discount",
          "records-per-page": 50,
          "sale-price-minimum": 1,
        },
      }
    );

    const products = response.data?.products?.product || [];
    console.log(`[CJ] Fetched ${products.length} products`);
    return products.map((p) => ({
      title: p.name || "",
      description: p.description || "",
      priceCurrent: parseFloat(p["sale-price"] || p.price || 0),
      priceWas: parseFloat(p["regular-price"] || 0) || null,
      vendor: p["advertiser-name"] || "",
      link: p["buy-url"] || "",
      imageUrl: p["image-url"] || "",
      category: mapCategory(p.category),
      source: "cj",
      createdAt: new Date(),
      price: parseFloat(p["sale-price"] || p.price || 0),
      originalPrice: parseFloat(p["regular-price"] || 0) || null,
    }));
  } catch (err) {
    console.error("[CJ] Fetch error:", err.message);
    return [];
  }
}

async function syncCJDealsToFirestore() {
  const deals = await fetchCJDeals();
  if (deals.length === 0) return 0;

  const batch = db.batch();
  let count = 0;

  for (const deal of deals) {
    const ref = db.collection("deals").doc();
    batch.set(ref, deal);
    count++;
  }

  await batch.commit();
  console.log(`[CJ] Synced ${count} deals to Firestore`);
  return count;
}

module.exports = { syncCJDealsToFirestore, fetchCJDeals };
