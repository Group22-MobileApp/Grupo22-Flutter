import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:goatsmart/firebase_options.dart';
import 'package:goatsmart/pages/home.dart';
import 'package:goatsmart/pages/login.dart';
import 'package:goatsmart/pages/itemGallery.dart';
import 'package:goatsmart/pages/registerPage.dart';
import 'package:goatsmart/preferences/pref_users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:goatsmart/utils/auth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserPreferences.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AuthService _authService = AuthService(); 
  final prefs = UserPreferences();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;          

          return MaterialApp(
            title: 'GoatSmart',
            theme: ThemeData(
              primaryColor: const Color(0xFF2E4053),
              colorScheme: ColorScheme.fromSwatch().copyWith(
                secondary: const Color(0xFFF7DC6F),
                tertiary: const Color(0xFFF5B041),
              ),
            ),
            home: HomePage(),
            routes: {
              LoginPage.routeName: (context) => LoginPage(),
              HomePage.routeName: (context) => const HomePage(),
              ItemGallery.routeName: (context) => ItemGallery(),
              RegisterPage.routeName: (context) => const RegisterPage(),
            },
          );
        } else {          
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }
}
