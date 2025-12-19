import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration for True Hadith app.
///
/// ⚠️ IMPORTANT: You MUST replace the placeholder values below with your actual Firebase credentials.
///
/// 📖 HOW TO GET YOUR FIREBASE WEB CONFIG:
/// 
/// Option 1: Using FlutterFire CLI (Recommended - Easiest)
///   1. Install: dart pub global activate flutterfire_cli
///   2. Run: flutterfire configure
///   3. Select your Firebase project and platforms
///   4. This file will be automatically updated with correct values
///
/// Option 2: Manual Setup from Firebase Console
///   1. Go to https://console.firebase.google.com/
///   2. Select your project (or create a new one)
///   3. Click the gear icon ⚙️ → Project Settings
///   4. Scroll down to "Your apps" section
///   5. Click the "</>" (Web) icon to add a web app
///   6. Register your app (give it a nickname like "True Hadith Web")
///   7. Copy the Firebase configuration object values:
///      - apiKey: Found in the config object as "apiKey"
///      - appId: Found as "appId" or "messagingSenderId" 
///      - messagingSenderId: Found as "messagingSenderId"
///      - projectId: Found as "projectId"
///      - authDomain: Found as "authDomain" (usually: projectId.firebaseapp.com)
///      - storageBucket: Found as "storageBucket" (usually: projectId.appspot.com)
///
/// 🔐 After updating values, make sure:
///   - Email/Password authentication is enabled in Firebase Console
///   - Go to: Authentication → Sign-in method → Enable Email/Password
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
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Web Firebase configuration
  /// 
  /// ⚠️ REPLACE THESE VALUES with your actual Firebase Web App config from Firebase Console
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'CHANGE_ME_API_KEY', // Get from Firebase Console → Project Settings → Web App config
    appId: 'CHANGE_ME_APP_ID', // Get from Firebase Console → Project Settings → Web App config
    messagingSenderId: 'CHANGE_ME_SENDER_ID', // Get from Firebase Console → Project Settings → Web App config
    projectId: 'CHANGE_ME_PROJECT_ID', // Your Firebase project ID
    authDomain: 'CHANGE_ME_AUTH_DOMAIN', // Usually: your-project-id.firebaseapp.com
    storageBucket: 'CHANGE_ME_STORAGE_BUCKET', // Usually: your-project-id.appspot.com
  );

  // For other platforms, using web config as fallback
  // You can configure platform-specific values later if needed
  static const FirebaseOptions android = web;
  static const FirebaseOptions ios = web;
  static const FirebaseOptions macos = web;
  static const FirebaseOptions windows = web;
  static const FirebaseOptions linux = web;
}

