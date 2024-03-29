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
    apiKey: 'AIzaSyDTo51bnNBWZcfrjjQbQVuSn5g5th_vFAI',
    appId: '1:181017795120:web:df36654f4b7388abc22bf5',
    messagingSenderId: '181017795120',
    projectId: 'bestowise-empire',
    authDomain: 'bestowise-empire.firebaseapp.com',
    storageBucket: 'bestowise-empire.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyARQWt1mnJl9-U974QdoAm416GFf_IGZTA',
    appId: '1:181017795120:android:cf0aabbb72506b58c22bf5',
    messagingSenderId: '181017795120',
    projectId: 'bestowise-empire',
    storageBucket: 'bestowise-empire.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAxUGU7TUkUvTC0JhmNpY4Onmv0WClc3Xk',
    appId: '1:181017795120:ios:a53211848744ea5bc22bf5',
    messagingSenderId: '181017795120',
    projectId: 'bestowise-empire',
    storageBucket: 'bestowise-empire.appspot.com',
    iosClientId:
        '181017795120-htrbinssne65bscb4la6viau1vhseji5.apps.googleusercontent.com',
    iosBundleId: 'com.empire.BestoWise',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAxUGU7TUkUvTC0JhmNpY4Onmv0WClc3Xk',
    appId: '1:181017795120:ios:a53211848744ea5bc22bf5',
    messagingSenderId: '181017795120',
    projectId: 'bestowise-empire',
    storageBucket: 'bestowise-empire.appspot.com',
    iosClientId:
        '181017795120-htrbinssne65bscb4la6viau1vhseji5.apps.googleusercontent.com',
    iosBundleId: 'com.empire.BestoWise',
  );
}
