// functions/scrapers/run_all.js

require("dotenv").config({ path: "../.env" });
const { syncCJDealsToFirestore } = require("./cj_scraper");
const { syncShareASaleDealsToFirestore } = require("./shareasale_scraper");
const { syncLocalDealsToFirestore } = require("./local_deals_scraper");
const { matchWantsToDeals } = require("./want_matcher");

async function runAll() {
  console.log("=== GrabMeADeal Scraper Run Starting ===");
  console.log(new Date().toISOString());
  console.log("========================================");

  // Step 1 — Sync deals from all sources
  const results = await Promise.allSettled([
    syncCJDealsToFirestore(),
    syncShareASaleDealsToFirestore(),
    syncLocalDealsToFirestore(),
  ]);

  let total = 0;
  const labels = ["CJ Affiliate", "ShareASale", "Local/Craigslist"];

  results.forEach((result, i) => {
    if (result.status === "fulfilled") {
      console.log(`✅ ${labels[i]}: ${result.value} deals synced`);
      total += result.value || 0;
    } else {
      console.error(`❌ ${labels[i]}: FAILED — ${result.reason}`);
    }
  });

  console.log("========================================");
  console.log(`Total deals synced: ${total}`);

  // Step 2 — Match wants to new deals
  console.log("========================================");
  console.log("Running Want List matcher...");
  const matches = await matchWantsToDeals();
  console.log(`Want List matches: ${matches}`);

  console.log("========================================");
  console.log("=== Scraper Run Complete ===");
  process.exit(0);
}

runAll().catch((err) => {
  console.error("Fatal error:", err);
  process.exit(1);
});
