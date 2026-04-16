// functions/scrapers/local_deals_scraper.js
// Scrapes publicly available local deal sources for TX markets
// Houston, Dallas, San Antonio, Austin

require("dotenv").config({ path: "../.env" });
const axios = require("axios");
const cheerio = require("cheerio");
const { db } = require("../firebase_init");

const TX_CITIES = ["Houston", "Dallas", "San Antonio", "Austin"];

// Craigslist free stuff and for sale sections (public)
const CRAIGSLIST_SOURCES = TX_CITIES.map((city) => ({
  city,
  url: `https://${city.toLowerCase().replace(" ", "")}.craigslist.org/search/sss?sort=date&postedToday=1`,
}));

async function scrapeLocalDeals() {
  const results = [];

  for (const source of CRAIGSLIST_SOURCES) {
    try {
      console.log(`[Local] Scraping ${source.city}...`);
      const response = await axios.get(source.url, {
        headers: {
          "User-Agent":
            "Mozilla/5.0 (compatible; GrabMeADealBot/1.0)",
        },
        timeout: 10000,
      });

      const $ = cheerio.load(response.data);

      $(".result-row").each((i, el) => {
        if (i >= 20) return false; // limit per city
        const title = $(el).find(".result-title").text().trim();
        const priceText = $(el).find(".result-price").text().trim();
        const price = parseFloat(priceText.replace(/[^0-9.]/g, "")) || 0;
        const link = $(el).find(".result-title").attr("href") || "";

        if (title && link) {
          results.push({
            title,
            description: `Local deal in ${source.city}, TX`,
            priceCurrent: price,
            priceWas: null,
            vendor: `Craigslist ${source.city}`,
            link,
            imageUrl: "",
            category: "homeGoods",
            source: "craigslist",
            city: source.city,
            state: "TX",
            createdAt: new Date(),
            price,
            originalPrice: null,
          });
        }
      });

      console.log(`[Local] ${source.city}: found ${results.length} deals so far`);
    } catch (err) {
      console.error(`[Local] ${source.city} error:`, err.message);
    }
  }

  return results;
}

async function syncLocalDealsToFirestore() {
  const deals = await scrapeLocalDeals();
  if (deals.length === 0) return 0;

  const batch = db.batch();
  let count = 0;

  for (const deal of deals) {
    const ref = db.collection("deals").doc();
    batch.set(ref, deal);
    count++;
  }

  await batch.commit();
  console.log(`[Local] Synced ${count} local deals to Firestore`);
  return count;
}

module.exports = { syncLocalDealsToFirestore, scrapeLocalDeals };
