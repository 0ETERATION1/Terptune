// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    // ENTER YOUR APIKEY FROM GOOGLE FIREBASE
    apiKey: '',
    appId: '1:1039845190462:web:693c1211373eea45aa1a6f',
    messagingSenderId: '1039845190462',
    projectId: 'terptune-f7746',
    authDomain: 'terptune-f7746.firebaseapp.com',
    storageBucket: 'terptune-f7746.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    // ENTER YOUR APIKEY FROM GOOGLE FIREBASE
    apiKey: '',
    appId: '1:1039845190462:android:a03821e138f6691baa1a6f',
    messagingSenderId: '1039845190462',
    projectId: 'terptune-f7746',
    storageBucket: 'terptune-f7746.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    // ENTER YOUR APIKEY FROM GOOGLE FIREBASE
    apiKey: '',
    appId: '1:1039845190462:ios:8f6855c131929ef1aa1a6f',
    messagingSenderId: '1039845190462',
    projectId: 'terptune-f7746',
    storageBucket: 'terptune-f7746.appspot.com',
    iosBundleId: 'com.example.terptune',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    // ENTER YOUR APIKEY FROM GOOGLE FIREBASE
    apiKey: '',
    appId: '1:1039845190462:ios:82b348da5b642dd3aa1a6f',
    messagingSenderId: '1039845190462',
    projectId: 'terptune-f7746',
    storageBucket: 'terptune-f7746.appspot.com',
    iosBundleId: 'com.example.terptune.RunnerTests',
  );
}
