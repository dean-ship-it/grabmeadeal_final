const admin = require("firebase-admin");
const serviceAccount = require("../serviceAccountKey.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: "grab-me-a-deal-e69ae",
});
const db = admin.firestore();

const deals = [
  { title: "Samsung 65\" QLED 4K Smart TV", description: "Crystal clear 4K display with Quantum HDR.", priceCurrent: 797.99, priceWas: 1299.99, price: 797.99, originalPrice: 1299.99, vendor: "Best Buy", category: "electronics", imageUrl: "https://images.unsplash.com/photo-1593359677879-a4bb92f829e1?w=400&q=80", link: "https://www.bestbuy.com", createdAt: new Date().toISOString() },
  { title: "PlayStation 5 Console Bundle", description: "PS5 disc edition with extra controller included.", priceCurrent: 499.99, priceWas: 649.99, price: 499.99, originalPrice: 649.99, vendor: "GameStop", category: "gaming", imageUrl: "https://images.unsplash.com/photo-1607853202273-797f1c22a38e?w=400&q=80", link: "https://www.gamestop.com", createdAt: new Date().toISOString() },
  { title: "Milwaukee M18 Drill & Impact Driver Combo", description: "18V cordless drill and impact driver with 2 batteries.", priceCurrent: 199.99, priceWas: 349.99, price: 199.99, originalPrice: 349.99, vendor: "Home Depot", category: "tools", imageUrl: "https://images.unsplash.com/photo-1504148455328-c376907d081c?w=400&q=80", link: "https://www.homedepot.com", createdAt: new Date().toISOString() },
  { title: "Ashley Sectional Sofa Gray", description: "Large L-shaped sectional with chaise. Stain resistant fabric.", priceCurrent: 699.99, priceWas: 1199.99, price: 699.99, originalPrice: 1199.99, vendor: "Ashley Furniture", category: "furniture", imageUrl: "https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&q=80", link: "https://www.ashleyfurniture.com", createdAt: new Date().toISOString() },
  { title: "Michelin Defender2 Tires Set of 4", description: "All-season tires with 80000 mile warranty.", priceCurrent: 549.99, priceWas: 799.99, price: 549.99, originalPrice: 799.99, vendor: "Discount Tire", category: "automotive", imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80", link: "https://www.discounttire.com", createdAt: new Date().toISOString() },
  { title: "Dyson Airwrap Complete Styler", description: "Multi-styler and dryer with 6 attachments.", priceCurrent: 449.99, priceWas: 599.99, price: 449.99, originalPrice: 599.99, vendor: "Sephora", category: "beauty", imageUrl: "https://images.unsplash.com/photo-1522338242992-e1a54906a8da?w=400&q=80", link: "https://www.sephora.com", createdAt: new Date().toISOString() },
  { title: "Nike Air Max 270 Running Shoes", description: "Lightweight with Max Air unit for all-day comfort.", priceCurrent: 89.99, priceWas: 150.00, price: 89.99, originalPrice: 150.00, vendor: "Nike", category: "apparel", imageUrl: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&q=80", link: "https://www.nike.com", createdAt: new Date().toISOString() },
  { title: "Purina Pro Plan Large Breed Dog Food 34lb", description: "High protein formula with real chicken for large breeds.", priceCurrent: 54.99, priceWas: 79.99, price: 54.99, originalPrice: 79.99, vendor: "Petco", category: "petSupplies", imageUrl: "https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=400&q=80", link: "https://www.petco.com", createdAt: new Date().toISOString() },
  { title: "Instant Pot Duo 7-in-1 Pressure Cooker", description: "6 quart multi-use electric pressure cooker.", priceCurrent: 59.99, priceWas: 99.99, price: 59.99, originalPrice: 99.99, vendor: "Target", category: "homeGoods", imageUrl: "https://images.unsplash.com/photo-1585515320310-259814833e62?w=400&q=80", link: "https://www.target.com", createdAt: new Date().toISOString() },
  { title: "Bowflex SelectTech 552 Adjustable Dumbbells", description: "Adjusts from 5 to 52.5 lbs. Replaces 15 sets of weights.", priceCurrent: 299.99, priceWas: 549.99, price: 299.99, originalPrice: 549.99, vendor: "Dicks Sporting Goods", category: "fitness", imageUrl: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&q=80", link: "https://www.dickssportinggoods.com", createdAt: new Date().toISOString() },
];

async function seed() {
  const batch = db.batch();
  deals.forEach(deal => {
    const ref = db.collection("deals").doc();
    batch.set(ref, deal);
  });
  await batch.commit();
  console.log(`✅ ${deals.length} deals uploaded successfully`);
  process.exit(0);
}

seed().catch(err => { console.error(err); process.exit(1); });
