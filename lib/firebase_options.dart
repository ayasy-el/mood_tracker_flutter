import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'Linux is not supported yet. Follow Firebase setup documentation for Linux.',
        );
      default:
        throw UnsupportedError(
          'Unknown platform ${defaultTargetPlatform}',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAafICw78cdYXRiX0fARb99w7QNhshU778',
    appId: '1:592318210326:android:78dc562a19db3ca8dfb037',
    messagingSenderId: '592318210326',
    projectId: 'mood-tracker-88805',
    storageBucket: 'mood-tracker-88805.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDuEW42AOol61QhKI2MI9QqF1W2tSwjECI',
    appId: '1:592318210326:ios:31670011f13f0856dfb037',
    messagingSenderId: '592318210326',
    projectId: 'mood-tracker-88805',
    storageBucket: 'mood-tracker-88805.firebasestorage.app',
    iosBundleId: 'com.example.moodTrackerFlutter',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBGPwposM7dh5-7uhXvteX2_gsQw9ipWik',
    appId: '1:592318210326:web:4f9ec4ab4a647e48dfb037',
    messagingSenderId: '592318210326',
    projectId: 'mood-tracker-88805',
    authDomain: 'mood-tracker-88805.firebaseapp.com',
    storageBucket: 'mood-tracker-88805.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDuEW42AOol61QhKI2MI9QqF1W2tSwjECI',
    appId: '1:592318210326:ios:31670011f13f0856dfb037',
    messagingSenderId: '592318210326',
    projectId: 'mood-tracker-88805',
    storageBucket: 'mood-tracker-88805.firebasestorage.app',
    iosBundleId: 'com.example.moodTrackerFlutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBGPwposM7dh5-7uhXvteX2_gsQw9ipWik',
    appId: '1:592318210326:web:8bda7441b95aed78dfb037',
    messagingSenderId: '592318210326',
    projectId: 'mood-tracker-88805',
    authDomain: 'mood-tracker-88805.firebaseapp.com',
    storageBucket: 'mood-tracker-88805.firebasestorage.app',
  );

}