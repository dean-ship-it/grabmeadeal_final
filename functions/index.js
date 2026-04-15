// functions/index.js
// Firebase Cloud Functions — scheduled deal sync
// Runs every 6 hours automatically

require("dotenv").config();
const functions = require("firebase-functions");
const { syncCJDealsToFirestore } = require("./scrapers/cj_scraper");
const { syncShareASaleDealsToFirestore } = require("./scrapers/shareasale_scraper");
const { syncLocalDealsToFirestore } = require("./scrapers/local_deals_scraper");
const { matchWantsToDeals } = require("./scrapers/want_matcher");

// Scheduled function — runs every 6 hours
exports.scheduledDealSync = functions.pubsub
  .schedule("every 6 hours")
  .onRun(async (context) => {
    console.log("[Scheduler] Starting deal sync...");

    await Promise.allSettled([
      syncCJDealsToFirestore(),
      syncShareASaleDealsToFirestore(),
      syncLocalDealsToFirestore(),
    ]);

    console.log("[Scheduler] Deal sync complete — running Want List matcher...");
    const matches = await matchWantsToDeals();
    console.log(`[Scheduler] Want List matches: ${matches}`);

    return null;
  });

// Manual trigger via HTTP for testing
exports.triggerDealSync = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).send("Method not allowed");
    return;
  }
  console.log("[HTTP Trigger] Manual deal sync triggered");

  await Promise.allSettled([
    syncCJDealsToFirestore(),
    syncShareASaleDealsToFirestore(),
    syncLocalDealsToFirestore(),
  ]);

  const matches = await matchWantsToDeals();
  res.json({ status: "ok", message: "Deal sync complete", wantMatches: matches });
});
