// C:\FlutterProjects\grabmeadeal_final\functions\upload_notifications.js

const admin = require("firebase-admin");
const fs = require("fs");
const path = require("path");

// Path to your service account key
const serviceAccount = require(path.join(__dirname, "serviceAccountKey.json"));

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// Example notifications to seed
const notifications = [
  {
    title: "Weekend Grocery Deals!",
    body: "Save 25% at Kroger and H-E-B this weekend.",
    category: "Grocery",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    title: "Electronics Sale",
    body: "Walmart & Costco laptops up to 40% off.",
    category: "Electronics",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

async function seedNotifications() {
  try {
    const batch = db.batch();
    notifications.forEach((notif) => {
      const docRef = db.collection("notifications").doc();
      batch.set(docRef, notif);
    });
    await batch.commit();
    console.log("✅ Notifications seeded successfully.");
    process.exit(0);
  } catch (error) {
    console.error("❌ Error seeding notifications:", error);
    process.exit(1);
  }
}

seedNotifications();
