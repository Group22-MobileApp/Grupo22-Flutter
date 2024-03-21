import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class FirebaseOptions {
  static FirebaseOptions get instance => FirebaseOptions._privateInstance;
  static FirebaseOptions _privateInstance = FirebaseOptions(
    appId: 'YOUR-APP-ID',
    apiKey: 'YOUR-API-KEY',
    messagingSenderId: 'YOUR-MESSAGING-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    databaseURL: 'YOUR-DATABASE-URL',
    storageBucket: 'YOUR-STORAGE-BUCKET',
  );
}