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
    apiKey: 'AIzaSyChi0xlcDO_bEBKva7OFdaDPQVgM-8qj4k',
    appId: '1:278596382225:web:86bdc5ef5cb21f23490bb0',
    messagingSenderId: '278596382225',
    projectId: 'act2-f01bc',
    authDomain: 'act2-f01bc.firebaseapp.com',
    storageBucket: 'act2-f01bc.firebasestorage.app',
    measurementId: 'G-5CFK9RB527',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBRZkVDDywvbyglFtuKPhiIZRhndb7h_Nw',
    appId: '1:278596382225:android:501da937fa731efd490bb0',
    messagingSenderId: '278596382225',
    projectId: 'act2-f01bc',
    storageBucket: 'act2-f01bc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBs1fASqqsn0Hp8F6ARaYJJKliPSL76Lvk',
    appId: '1:278596382225:ios:df9a93daad8f1757490bb0',
    messagingSenderId: '278596382225',
    projectId: 'act2-f01bc',
    storageBucket: 'act2-f01bc.firebasestorage.app',
    iosBundleId: 'com.example.productListApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBs1fASqqsn0Hp8F6ARaYJJKliPSL76Lvk',
    appId: '1:278596382225:ios:df9a93daad8f1757490bb0',
    messagingSenderId: '278596382225',
    projectId: 'act2-f01bc',
    storageBucket: 'act2-f01bc.firebasestorage.app',
    iosBundleId: 'com.example.productListApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyChi0xlcDO_bEBKva7OFdaDPQVgM-8qj4k',
    appId: '1:278596382225:web:061621e1d3c74eb7490bb0',
    messagingSenderId: '278596382225',
    projectId: 'act2-f01bc',
    authDomain: 'act2-f01bc.firebaseapp.com',
    storageBucket: 'act2-f01bc.firebasestorage.app',
    measurementId: 'G-DMXJF60DGD',
  );
}
