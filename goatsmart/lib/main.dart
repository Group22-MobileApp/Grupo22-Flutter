import 'dart:html';

import 'package:flutter/material.dart';
//Import home.dart from pages folder
import 'package:goatsmart/pages/home.dart';
//Import Firebase.initializeApp"
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp().then((value) => {
    runApp(MyApp())
  });
  
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoatSmart',
      theme: ThemeData(        
        // Want to use three colors for my app: 2E4053, F7DC6F, F5B041
        primaryColor: Color(0xFF2E4053),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Color(0xFFF7DC6F), tertiary: Color(0xFFF5B041)),

      ),
      home: Home(),
      
    );
  }
}
