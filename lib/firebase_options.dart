// Replace this content with the output from `flutterfire configure` if needed.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCgTqCMMvek-N1dNns_DZwro6DuhdEAHz8',
    appId: '1:346101400207:web:318faa1d4bba39e839a6fa',
    messagingSenderId: '346101400207',
    projectId: 'grab-me-a-deal-e69ae',
    authDomain: 'grab-me-a-deal-e69ae.firebaseapp.com',
    storageBucket: 'grab-me-a-deal-e69ae.firebasestorage.app',
    measurementId: 'G-MEASUREMENT-ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCgTqCMMvek-N1dNns_DZwro6DuhdEAHz8',
    appId: '1:346101400207:android:025706c3849ce53139a6fa',
    messagingSenderId: '346101400207',
    projectId: 'grab-me-a-deal-e69ae',
    storageBucket: 'grab-me-a-deal-e69ae.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'grab-me-a-deal-e69ae',
    storageBucket: 'grab-me-a-deal-e69ae.appspot.com',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.grabmeadeal.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'grab-me-a-deal-e69ae',
    storageBucket: 'grab-me-a-deal-e69ae.appspot.com',
  );
}
