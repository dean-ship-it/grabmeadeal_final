const admin = require("firebase-admin");
const path = require("path");
const serviceAccount = require(path.resolve("C:/FlutterProjects/grabmeadeal_final/serviceAccountKey.json"));
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: "grab-me-a-deal-e69ae",
});
const db = admin.firestore();

const groceryDeals = [
  {
    title: "HEB Primo Picks Wagyu Beef Bundle",
    description: "Premium Wagyu ground beef 3lb pack. Texas raised, locally sourced. Perfect for burgers and tacos.",
    priceCurrent: 24.99, priceWas: 39.99, price: 24.99, originalPrice: 39.99,
    vendor: "HEB", category: "grocery",
    imageUrl: "https://images.unsplash.com/photo-1603048297172-c92544798d5a?w=400&q=80",
    link: "https://www.heb.com",
    createdAt: new Date().toISOString(),
  },
  {
    title: "Costco Kirkland Signature Coffee 3lb",
    description: "100% Colombian medium roast whole bean coffee. 3 pound bag — best value per cup.",
    priceCurrent: 19.99, priceWas: 29.99, price: 19.99, originalPrice: 29.99,
    vendor: "Costco", category: "grocery",
    imageUrl: "https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400&q=80",
    link: "https://www.costco.com",
    createdAt: new Date().toISOString(),
  },
  {
    title: "Walmart Great Value Organic Milk Gallon",
    description: "USDA certified organic whole milk. No artificial hormones. Family size gallon.",
    priceCurrent: 5.48, priceWas: 7.99, price: 5.48, originalPrice: 7.99,
    vendor: "Walmart", category: "grocery",
    imageUrl: "https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&q=80",
    link: "https://www.walmart.com",
    createdAt: new Date().toISOString(),
  },
  {
    title: "HEB Meal Simple Family Dinner Kit",
    description: "Complete dinner kit for 4. Ready in 30 minutes. Includes protein, sides, and sauce. Changes weekly.",
    priceCurrent: 18.99, priceWas: 28.99, price: 18.99, originalPrice: 28.99,
    vendor: "HEB", category: "grocery",
    imageUrl: "https://images.unsplash.com/photo-1466637574441-749b8f19452f?w=400&q=80",
    link: "https://www.heb.com",
    createdAt: new Date().toISOString(),
  },
];

async function seed() {
  const batch = db.batch();
  groceryDeals.forEach(deal => {
    const ref = db.collection("deals").doc();
    batch.set(ref, deal);
  });
  await batch.commit();
  console.log(`✅ ${groceryDeals.length} grocery deals uploaded`);
  process.exit(0);
}

seed().catch(err => { console.error(err); process.exit(1); });
