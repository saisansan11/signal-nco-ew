// Firebase configuration for signal_nco_ew
// Generated from Firebase Console

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
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDBZMA9Of2cMCIPgEnbO1nhP_T2W2sdXoU',
    appId: '1:588884441324:web:1e40924f942b0df6070dc9',
    messagingSenderId: '588884441324',
    projectId: 'signal-nco-ew',
    authDomain: 'signal-nco-ew.firebaseapp.com',
    storageBucket: 'signal-nco-ew.firebasestorage.app',
    measurementId: 'G-EECS7R3JHX',
  );

  // Android config - same project, will be auto-configured when needed
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDBZMA9Of2cMCIPgEnbO1nhP_T2W2sdXoU',
    appId: '1:588884441324:web:1e40924f942b0df6070dc9',
    messagingSenderId: '588884441324',
    projectId: 'signal-nco-ew',
    storageBucket: 'signal-nco-ew.firebasestorage.app',
  );

  // iOS config - placeholder
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDBZMA9Of2cMCIPgEnbO1nhP_T2W2sdXoU',
    appId: '1:588884441324:web:1e40924f942b0df6070dc9',
    messagingSenderId: '588884441324',
    projectId: 'signal-nco-ew',
    storageBucket: 'signal-nco-ew.firebasestorage.app',
    iosBundleId: 'com.signalschool.signalNcoEw',
  );

  // macOS config - placeholder
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDBZMA9Of2cMCIPgEnbO1nhP_T2W2sdXoU',
    appId: '1:588884441324:web:1e40924f942b0df6070dc9',
    messagingSenderId: '588884441324',
    projectId: 'signal-nco-ew',
    storageBucket: 'signal-nco-ew.firebasestorage.app',
    iosBundleId: 'com.signalschool.signalNcoEw',
  );

  // Windows config - placeholder
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDBZMA9Of2cMCIPgEnbO1nhP_T2W2sdXoU',
    appId: '1:588884441324:web:1e40924f942b0df6070dc9',
    messagingSenderId: '588884441324',
    projectId: 'signal-nco-ew',
    storageBucket: 'signal-nco-ew.firebasestorage.app',
  );
}
