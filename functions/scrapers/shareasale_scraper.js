// functions/scrapers/shareasale_scraper.js
// ShareASale API scraper
// Sign up free at shareasale.com to get API credentials

require("dotenv").config({ path: "../.env" });
const axios = require("axios");
const crypto = require("crypto");
const { db } = require("../firebase_init");

const TOKEN = process.env.SHAREASALE_API_TOKEN;
const SECRET = process.env.SHAREASALE_API_SECRET;
const AFFILIATE_ID = process.env.SHAREASALE_AFFILIATE_ID;

function buildSignature(action, date) {
  const sigString = `${TOKEN}:${date}:${action}:${SECRET}`;
  return crypto.createHash("sha256").update(sigString).digest("hex");
}

async function fetchShareASaleDeals() {
  if (!TOKEN || TOKEN === "your_shareasale_token_here") {
    console.log("[ShareASale] API token not configured — skipping");
    return [];
  }

  try {
    console.log("[ShareASale] Fetching deals...");
    const action = "dealfeed";
    const date = new Date().toUTCString();
    const sig = buildSignature(action, date);

    const response = await axios.get(
      "https://api.shareasale.com/w.cfm",
      {
        params: {
          token: TOKEN,
          affiliateId: AFFILIATE_ID,
          version: "2.8",
          action,
          XMLFormat: "1",
        },
        headers: {
          "x-ShareASale-Date": date,
          "x-ShareASale-Authentication": sig,
        },
      }
    );

    const deals = response.data?.deals?.deal || [];
    const dealArray = Array.isArray(deals) ? deals : [deals];
    console.log(`[ShareASale] Fetched ${dealArray.length} deals`);

    return dealArray.map((d) => ({
      title: d.dealTitle || d.merchantName || "",
      description: d.dealDescription || "",
      priceCurrent: parseFloat(d.salePrice || d.price || 0),
      priceWas: parseFloat(d.regularPrice || 0) || null,
      vendor: d.merchantName || "",
      link: d.trackingUrl || d.dealUrl || "",
      imageUrl: d.imageUrl || "",
      category: "homeGoods",
      source: "shareasale",
      createdAt: new Date(),
      price: parseFloat(d.salePrice || d.price || 0),
      originalPrice: parseFloat(d.regularPrice || 0) || null,
    }));
  } catch (err) {
    console.error("[ShareASale] Fetch error:", err.message);
    return [];
  }
}

async function syncShareASaleDealsToFirestore() {
  const deals = await fetchShareASaleDeals();
  if (deals.length === 0) return 0;

  const batch = db.batch();
  let count = 0;

  for (const deal of deals) {
    const ref = db.collection("deals").doc();
    batch.set(ref, deal);
    count++;
  }

  await batch.commit();
  console.log(`[ShareASale] Synced ${count} deals to Firestore`);
  return count;
}

module.exports = { syncShareASaleDealsToFirestore, fetchShareASaleDeals };
