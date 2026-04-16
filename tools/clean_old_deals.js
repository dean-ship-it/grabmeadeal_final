const admin = require("firebase-admin");
const serviceAccount = require("../serviceAccountKey.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: "grab-me-a-deal-e69ae",
});
const db = admin.firestore();

async function cleanOldDeals() {
  const snap = await db.collection("deals").get();
  const batch = db.batch();
  let count = 0;

  snap.docs.forEach(doc => {
    const data = doc.data();
    const imageUrl = data.imageUrl || data.link || "";
    const price = data.priceCurrent || data.price || 0;
    const isBroken = imageUrl.includes("example.com") ||
      imageUrl.includes("imgur.com") ||
      imageUrl.includes("harborfreight") ||
      imageUrl === "" ||
      price === 0;

    if (isBroken) {
      batch.delete(doc.ref);
      count++;
      console.log(`Deleting: ${data.title}`);
    }
  });

  await batch.commit();
  console.log(`✅ Deleted ${count} old/broken deals`);
  process.exit(0);
}

cleanOldDeals().catch(err => { console.error(err); process.exit(1); });
