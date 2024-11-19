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
   apiKey: "AIzaSyD6u4TuTGwkOyh1avilDVCnM6BmXj-sFwE",
  authDomain: "whaletasks.firebaseapp.com",
  databaseURL: "https://whaletasks-default-rtdb.firebaseio.com",
  projectId: "whaletasks",
  storageBucket: "whaletasks.appspot.com",
  messagingSenderId: "111458068547",
  appId: "1:111458068547:web:fda3f5fc99ff343c484cf6",
  measurementId: "G-PBBD5VXYRL"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDLcSi9YFhWh1EfyWIDZJqcl2fXRcCxoWA',
    appId: '1:111458068547:android:f219b09b276dd221484cf6',
    messagingSenderId: '111458068547',
    projectId: 'whaletasks',
    databaseURL: 'https://whaletasks-default-rtdb.firebaseio.com',
    storageBucket: 'whaletasks.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAiYFe6b24VO-GSpGEvwS2IBso1G2G8UEQ',
    appId: '1:111458068547:ios:762289a594edfe73484cf6',
    messagingSenderId: '111458068547',
    projectId: 'whaletasks',
    databaseURL: 'https://whaletasks-default-rtdb.firebaseio.com',
    storageBucket: 'whaletasks.appspot.com',
    iosClientId: '111458068547-tjlfeuav2p2tlu3s41i6prkr2q0occ43.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterTodoApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAiYFe6b24VO-GSpGEvwS2IBso1G2G8UEQ',
    appId: '1:111458068547:ios:762289a594edfe73484cf6',
    messagingSenderId: '111458068547',
    projectId: 'whaletasks',
    databaseURL: 'https://whaletasks-default-rtdb.firebaseio.com',
    storageBucket: 'whaletasks.appspot.com',
    iosClientId: '111458068547-tjlfeuav2p2tlu3s41i6prkr2q0occ43.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterTodoApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD6u4TuTGwkOyh1avilDVCnM6BmXj-sFwE',
    appId: '1:111458068547:web:2b9bc9895f86c70a484cf6',
    messagingSenderId: '111458068547',
    projectId: 'whaletasks',
    authDomain: 'whaletasks.firebaseapp.com',
    databaseURL: 'https://whaletasks-default-rtdb.firebaseio.com',
    storageBucket: 'whaletasks.appspot.com',
    measurementId: 'G-4XEPJ40HHY',
  );
}