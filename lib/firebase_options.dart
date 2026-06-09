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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBkD6Jggfxs5_8pbN1bzGfMktiW0rX4R_I',
    appId: '1:213375994118:web:673e6278b4126313d6f687',
    messagingSenderId: '213375994118',
    projectId: 'cupple-app-a9194',
    storageBucket: 'cupple-app-a9194.firebasestorage.app',
    authDomain: 'cupple-app-a9194.firebaseapp.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCL5bmd0V-HTQ9cKDCmwI5Yi-eLVdxwhwg',
    appId: '1:213375994118:android:d14bd9b61e4b9a26d6f687',
    messagingSenderId: '213375994118',
    projectId: 'cupple-app-a9194',
    storageBucket: 'cupple-app-a9194.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAlGRAC-1IlWTyt6B5OgCT10ToGY9zx_z0',
    appId: '1:213375994118:ios:6f8fdc24c8e2841ad6f687',
    messagingSenderId: '213375994118',
    projectId: 'cupple-app-a9194',
    storageBucket: 'cupple-app-a9194.firebasestorage.app',
  );
}
