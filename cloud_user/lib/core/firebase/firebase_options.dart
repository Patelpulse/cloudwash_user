import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

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
    apiKey: 'AIzaSyDQgMfagJiN16By-sS4fbAM0Kf6omkSRG8',
    authDomain: 'cloudwash-6ceb6.firebaseapp.com',
    projectId: 'cloudwash-6ceb6',
    storageBucket: 'cloudwash-6ceb6.firebasestorage.app',
    messagingSenderId: '864806051234',
    appId: '1:864806051234:web:ce326d49512cc22f8a26fb',
    measurementId: 'G-QT8J7LWT3Y',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDRIGbcvURX41hw9lcvkGFtCrPn1wbwzek',
    appId: '1:864806051234:android:96bc248adb99fa778a26fb',
    messagingSenderId: '864806051234',
    projectId: 'cloudwash-6ceb6',
    storageBucket: 'cloudwash-6ceb6.firebasestorage.app',
  );
}
