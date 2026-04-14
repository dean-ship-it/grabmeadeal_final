// web/firebase-messaging-sw.js

importScripts("https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js");

// Read firebase_options.dart for these values and fill them in here
firebase.initializeApp({
  apiKey: "AIzaSyCgTqCMMvek-N1dNns_DZwro6DuhdEAHz8",
  authDomain: "grab-me-a-deal-e69ae.firebaseapp.com",
  projectId: "grab-me-a-deal-e69ae",
  storageBucket: "grab-me-a-deal-e69ae.firebasestorage.app",
  messagingSenderId: "346101400207",
  appId: "1:346101400207:web:318faa1d4bba39e839a6fa",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log("[firebase-messaging-sw.js] Background message received:", payload);
  const { title, body } = payload.notification ?? {};
  if (title) {
    self.registration.showNotification(title, {
      body: body ?? "",
      icon: "/icons/Icon-192.png",
    });
  }
});
