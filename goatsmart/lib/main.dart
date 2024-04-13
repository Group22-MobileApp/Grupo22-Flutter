import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:goatsmart/firebase_options.dart';
import 'package:goatsmart/pages/home.dart';
import 'package:goatsmart/pages/login.dart';
import 'package:goatsmart/pages/itemGallery.dart';
import 'package:goatsmart/pages/registerPage.dart';
import 'package:goatsmart/preferences/pref_users.dart';

void main() async{  
  WidgetsFlutterBinding.ensureInitialized();
  await UserPreferences.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final prefs = UserPreferences();

  @override
  Widget build(BuildContext context) {    
    return MaterialApp(
      title: 'GoatSmart',
      theme: ThemeData(                
        primaryColor: const Color(0xFF2E4053),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: const Color(0xFFF7DC6F), tertiary: const Color(0xFFF5B041)),

      ),
      initialRoute: prefs.lastPage,      
      routes: {
        LoginPage.routeName: (context) => const LoginPage(),
        HomePage.routeName: (context) => const HomePage(),
        ItemGallery.routeName: (context) => const ItemGallery(), 
        RegisterPage.routename: (context) => const RegisterPage(),        
      },
    );
  }
}