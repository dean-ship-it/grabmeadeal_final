// functions/firebase_init.js
const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId: process.env.FIREBASE_PROJECT_ID || "grab-me-a-deal-e69ae",
  });
}

const db = admin.firestore();
module.exports = { admin, db };
