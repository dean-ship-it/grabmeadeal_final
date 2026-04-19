// tools/seed_recommended_demo.js
//
// Seeds 3 demo "high-frequency" deals (gas + coffee + lunch) and configures
// the featured/current_recommended doc with a TIME-OF-DAY ROTATION.
//
// The Deals page hero auto-rotates based on current local time — coffee in
// the morning, lunch at midday, gas in the afternoon/evening. No more
// "coffee deal at 4pm" or "lunch deal at 6am."
//
// Strategy notes in memory/roadmap_visual_features.md.
//
// Run:  node tools/seed_recommended_demo.js
//
// Idempotent — uses fixed deal IDs so re-running won't create duplicates.

const admin = require("firebase-admin");
const serviceAccount = require("../serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: "grab-me-a-deal-e69ae",
});

const db = admin.firestore();
const now = new Date();

// Three demo high-frequency deals
const demoDeals = [
  {
    id: "demo_gas_chevron",
    data: {
      title: "Save \$0.20/gal at Chevron",
      description:
        "Today only — fill up at any Chevron near you and save 20¢ per gallon. Average $3 savings on a typical fill-up. Use the app to find the closest location.",
      vendor: "Chevron",
      category: "automotive",
      subcategory: "gas",
      imageUrl:
        "https://images.unsplash.com/photo-1545459720-aac8509eb02c?w=800&q=80",
      price: 0,
      originalPrice: 0,
      dealUrl: "https://www.chevron.com",
      keywords: ["gas", "fuel", "chevron", "savings", "daily"],
      createdAt: now.toISOString(),
      isHighFrequency: true,
      dealType: "savings_per_unit",
    },
  },
  {
    id: "demo_coffee_starbucks",
    data: {
      title: "\$2 off any Starbucks drink",
      description:
        "Grab a coffee on your way to work — $2 off any handcrafted drink at participating Starbucks today. Valid through 11am.",
      vendor: "Starbucks",
      category: "food",
      subcategory: "coffee",
      imageUrl:
        "https://images.unsplash.com/photo-1559496417-e7f25cb247f3?w=800&q=80",
      price: 5.45,
      originalPrice: 7.45,
      dealUrl: "https://www.starbucks.com",
      keywords: ["coffee", "starbucks", "morning", "savings", "daily"],
      createdAt: now.toISOString(),
      isHighFrequency: true,
      dealType: "fixed_discount",
    },
  },
  {
    id: "demo_lunch_chipotle",
    data: {
      title: "BOGO Burritos at Chipotle",
      description:
        "Lunch hour just got better — buy one burrito, get one free at any Chipotle near you. Valid 11am-3pm today only.",
      vendor: "Chipotle",
      category: "food",
      subcategory: "lunch",
      imageUrl:
        "https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=800&q=80",
      price: 9.50,
      originalPrice: 19.00,
      dealUrl: "https://www.chipotle.com",
      keywords: ["lunch", "chipotle", "burrito", "bogo", "midday"],
      createdAt: now.toISOString(),
      isHighFrequency: true,
      dealType: "bogo",
    },
  },
];

// Time-of-day rotation. App picks the first entry whose hour window matches
// the user's current local time. Hours are 24-hour format (0-23).
// `endHour` is exclusive. For wrap-around windows (e.g., 22-5), set startHour
// > endHour and the app handles it.
const rotation = [
  {
    dealId: "demo_coffee_starbucks",
    badgeText: "☕ MORNING PICK",
    startHour: 5,  // 5am
    endHour: 11,   // 11am (exclusive)
  },
  {
    dealId: "demo_lunch_chipotle",
    badgeText: "🥗 LUNCH NEAR YOU",
    startHour: 11, // 11am
    endHour: 15,   // 3pm
  },
  {
    dealId: "demo_coffee_starbucks",
    badgeText: "☕ AFTERNOON PICK-ME-UP",
    startHour: 15, // 3pm
    endHour: 17,   // 5pm
  },
  {
    dealId: "demo_lunch_chipotle",
    badgeText: "🍽️ DINNER NEAR YOU",
    startHour: 17, // 5pm
    endHour: 22,   // 10pm
  },
  {
    dealId: "demo_gas_chevron",
    badgeText: "⛽ FILL UP TONIGHT",
    startHour: 22, // 10pm
    endHour: 5,    // 5am next day (wrap-around)
  },
];

async function main() {
  // Upsert demo deals
  const batch = db.batch();
  for (const d of demoDeals) {
    const ref = db.collection("deals").doc(d.id);
    batch.set(ref, d.data, { merge: true });
  }
  await batch.commit();
  console.log(`✅ Upserted ${demoDeals.length} demo deals`);

  // Configure the rotation
  await db.doc("featured/current_recommended").set({
    enabled: true,
    rotation: rotation,
    // Hard fallback if all rotation windows somehow miss (shouldn't happen):
    dealId: "demo_gas_chevron",
    badgeText: "⛽ TODAY ONLY",
    updatedAt: now.toISOString(),
    note:
      "Time-of-day rotation seeded by seed_recommended_demo.js. Edit the " +
      "rotation array to change which deal shows when. Set enabled:false " +
      "to disable curation entirely (falls back to highest-discount-with-image).",
  });
  console.log(`✅ Set rotation with ${rotation.length} time windows`);

  console.log("\nRotation schedule:");
  for (const r of rotation) {
    console.log(`  ${pad(r.startHour)}-${pad(r.endHour)}: ${r.badgeText} → ${r.dealId}`);
  }

  const currentHour = now.getHours();
  const active = pickActive(rotation, currentHour);
  console.log(
    `\nRight now (hour ${currentHour}): showing "${active.badgeText}" → ${active.dealId}`
  );

  process.exit(0);
}

function pad(h) {
  return String(h).padStart(2, "0") + ":00";
}

function pickActive(rotation, currentHour) {
  for (const r of rotation) {
    if (r.startHour < r.endHour) {
      if (currentHour >= r.startHour && currentHour < r.endHour) return r;
    } else {
      // Wrap-around (e.g., 22-5)
      if (currentHour >= r.startHour || currentHour < r.endHour) return r;
    }
  }
  return rotation[0];
}

main().catch((err) => {
  console.error("ERROR:", err);
  process.exit(1);
});
