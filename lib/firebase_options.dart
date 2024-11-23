// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyD56Ol4b6ghrLIbrkl4KOKeSmn2yjBmyZM',
    appId: '1:955710325004:web:6a4f107e8eaf1563cb0929',
    messagingSenderId: '955710325004',
    projectId: 'controle-de-abasteciment-6a47e',
    authDomain: 'controle-de-abasteciment-6a47e.firebaseapp.com',
    storageBucket: 'controle-de-abasteciment-6a47e.firebasestorage.app',
    measurementId: 'G-TKWHT9435P',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA3dTQtzroE3ejqHrF9V1Xuy6zpFVuvSFg',
    appId: '1:955710325004:android:e458aa25d6ad9445cb0929',
    messagingSenderId: '955710325004',
    projectId: 'controle-de-abasteciment-6a47e',
    storageBucket: 'controle-de-abasteciment-6a47e.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD56Ol4b6ghrLIbrkl4KOKeSmn2yjBmyZM',
    appId: '1:955710325004:web:d7a69c426b882f9dcb0929',
    messagingSenderId: '955710325004',
    projectId: 'controle-de-abasteciment-6a47e',
    authDomain: 'controle-de-abasteciment-6a47e.firebaseapp.com',
    storageBucket: 'controle-de-abasteciment-6a47e.firebasestorage.app',
    measurementId: 'G-G8MNL0JSPY',
  );
}
