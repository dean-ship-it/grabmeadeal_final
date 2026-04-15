// functions/scrapers/want_matcher.js

require("dotenv").config({ path: "../.env" });
const { db, admin } = require("../firebase_init");

async function matchWantsToDeals() {
  console.log("[WantMatcher] Starting want list matching...");

  try {
    // Get all deals from last 24 hours
    const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const dealsSnap = await db.collection("deals")
      .where("createdAt", ">=", oneDayAgo.toISOString())
      .get();

    if (dealsSnap.empty) {
      console.log("[WantMatcher] No new deals in last 24 hours");
      return 0;
    }

    const deals = dealsSnap.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    console.log(`[WantMatcher] Checking ${deals.length} new deals against want lists`);

    // Get all users
    const usersSnap = await db.collection("users").get();
    let totalMatches = 0;

    for (const userDoc of usersSnap.docs) {
      const uid = userDoc.id;

      // Get active wants for this user
      const wantsSnap = await db
        .collection("users")
        .doc(uid)
        .collection("wants")
        .where("active", "==", true)
        .get();

      if (wantsSnap.empty) continue;

      const wants = wantsSnap.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
      }));

      for (const want of wants) {
        const keyword = (want.keyword || "").toLowerCase();
        const maxPrice = want.maxPrice || Infinity;

        for (const deal of deals) {
          const title = (deal.title || "").toLowerCase();
          const description = (deal.description || "").toLowerCase();
          const vendor = (deal.vendor || "").toLowerCase();
          const dealPrice = deal.priceCurrent || deal.price || 0;
          const dealCategory = deal.category || "";

          // Check keyword match
          const keywordMatch = title.includes(keyword) ||
            description.includes(keyword) ||
            vendor.includes(keyword);

          // Check price match
          const priceMatch = dealPrice <= maxPrice;

          // Check category match if specified
          const categoryMatch = !want.category ||
            dealCategory === want.category;

          if (keywordMatch && priceMatch && categoryMatch) {
            console.log(`[WantMatcher] Match found: "${want.keyword}" → "${deal.title}" for user ${uid}`);

            // Update want item with match info
            await db.collection("users").doc(uid)
              .collection("wants").doc(want.id)
              .update({
                lastMatchedAt: new Date().toISOString(),
                lastMatchedDealId: deal.id,
              });

            // Send FCM notification to user
            await sendDealAlert(uid, want.keyword, deal);
            totalMatches++;
            break; // One notification per want per run
          }
        }
      }
    }

    console.log(`[WantMatcher] Total matches found: ${totalMatches}`);
    return totalMatches;

  } catch (err) {
    console.error("[WantMatcher] Error:", err.message);
    return 0;
  }
}

async function sendDealAlert(uid, keyword, deal) {
  try {
    // Get user's FCM token from Firestore
    const userDoc = await db.collection("users").doc(uid).get();
    const fcmToken = userDoc.data()?.fcmToken;

    if (!fcmToken) {
      console.log(`[WantMatcher] No FCM token for user ${uid}`);
      return;
    }

    const message = {
      token: fcmToken,
      notification: {
        title: "🎯 Deal Alert — " + keyword,
        body: `${deal.title} is available for $${(deal.priceCurrent || deal.price || 0).toFixed(2)}`,
      },
      data: {
        dealId: deal.id,
        route: "/deal-detail",
        keyword,
      },
      android: {
        priority: "high",
        notification: {
          channelId: "grabmeadeal_default",
          icon: "ic_launcher",
          color: "#0075C9",
        },
      },
    };

    await admin.messaging().send(message);
    console.log(`[WantMatcher] Alert sent to user ${uid} for "${keyword}"`);

    // Store notification in Firestore
    await db.collection("notifications").doc(uid)
      .collection("items").add({
        title: "🎯 Deal Alert — " + keyword,
        body: `${deal.title} is available for $${(deal.priceCurrent || deal.price || 0).toFixed(2)}`,
        dealId: deal.id,
        keyword,
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

  } catch (err) {
    console.error("[WantMatcher] Send alert error:", err.message);
  }
}

module.exports = { matchWantsToDeals };
