import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "AIzaSyBt3Vapz2NYYFXcU24Zf57sUmubYbw3qOY",
      appId: "1:446769909483:web:b1ba5e9c9f017371bd78ae",
      messagingSenderId: "446769909483",
      projectId: "smartlocker-519a0",
      databaseURL: "https://smartlocker-519a0-default-rtdb.asia-southeast1.firebasedatabase.app",
      storageBucket: "smartlocker-519a0.firebasestorage.app",
    );
  }
}