import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
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

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyARFxSCJRvXug2_o1PqXT2ce63ixKw0pk4',
    appId: '1:25966670578:ios:44ce8c596fd4028469d66b',
    messagingSenderId: '25966670578',
    projectId: 'vivaclub-c5f16',
    iosBundleId: 'com.vivaclub.vivaClub',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA9YK7fszM0-fsmk8qMA_1cvMq7T15IN-E',
    appId: '1:25966670578:android:1507c9d73931341b69d66b',
    messagingSenderId: '25966670578',
    projectId: 'vivaclub-c5f16',
    storageBucket: 'vivaclub-c5f16.firebasestorage.app',
  );
}
