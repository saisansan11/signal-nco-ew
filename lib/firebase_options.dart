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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA89UIq7gsPM1NDtm6HjyyvdbvdC1-_BCM',
    appId: '1:588884441324:android:01db426bd5f6951e070dc9',
    messagingSenderId: '588884441324',
    projectId: 'signal-nco-ew',
    storageBucket: 'signal-nco-ew.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDvsaCPIc9lhVzeBFHt9iSwQwkUb5o5mLM',
    appId: '1:588884441324:ios:a2acdf1bef977d87070dc9',
    messagingSenderId: '588884441324',
    projectId: 'signal-nco-ew',
    storageBucket: 'signal-nco-ew.firebasestorage.app',
    iosClientId: '588884441324-r27rpev0u3f8q1i5hbfb1kgbt1dm44l9.apps.googleusercontent.com',
    iosBundleId: 'com.signalschool.signalNcoEw',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDBZMA9Of2cMCIPgEnbO1nhP_T2W2sdXoU',
    appId: '1:588884441324:web:1e40924f942b0df6070dc9',
    messagingSenderId: '588884441324',
    projectId: 'signal-nco-ew',
    storageBucket: 'signal-nco-ew.firebasestorage.app',
    iosBundleId: 'com.signalschool.signalNcoEw',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD_2t0TBFJoZOEnneFImUhpfxt_1MvRIAI',
    appId: '1:588884441324:web:44f58a540dfded92070dc9',
    messagingSenderId: '588884441324',
    projectId: 'signal-nco-ew',
    authDomain: 'signal-nco-ew.firebaseapp.com',
    storageBucket: 'signal-nco-ew.firebasestorage.app',
    measurementId: 'G-FX6HYX269N',
  );

}