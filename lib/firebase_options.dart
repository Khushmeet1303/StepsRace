// ⚠️  PLACEHOLDER — Replace with your real Firebase config.
//
// HOW TO GET THIS FILE:
//  1. Go to https://console.firebase.google.com → your project
//  2. Click the Flutter icon (</>) → follow the FlutterFire CLI steps:
//       dart pub global activate flutterfire_cli
//       flutterfire configure
//  3. That command auto-generates this file. Replace this file with it.
//
// Alternatively (manual):
//  1. Firebase Console → Project Settings → Your apps
//  2. Add an Android app (package: com.example.step_race)
//     and an iOS app (bundle: com.example.stepRace)
//  3. Download google-services.json (Android) and GoogleService-Info.plist (iOS)
//  4. Place google-services.json in  android/app/
//  5. Place GoogleService-Info.plist in  ios/Runner/
//  6. Fill in the values below from Firebase Console → Project Settings → General

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web not supported');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  // ── FILL THESE IN ──────────────────────────────────────────────────────────
  // Find all values in Firebase Console → Project Settings → General → Your apps
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA3_eKq_FPXrY_6hQTqRtsejDeodpg2nDc',
    appId: '1:17096587187:android:f2bfd2bdaedd0c7945fdc6',
    messagingSenderId: '17096587187',
    projectId: 'steps-race',
    storageBucket: 'steps-race.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',                   // e.g. 1:123456789:ios:abc123
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.stepRace',
  );
}
