import 'package:flutter/material.dart';
//Import home.dart from pages folder
import 'package:goatsmart/pages/home.dart';
import 'package:goatsmart/pages/login.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoatSmart',
      theme: ThemeData(        
        // Want to use three colors for my app: 2E4053, F7DC6F, F5B041
        primaryColor: const Color(0xFF2E4053),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: const Color(0xFFF7DC6F), tertiary: const Color(0xFFF5B041)),

      ),
      initialRoute: '/', // This is the route that the app will start on
      routes: {
        '/': (context) => const Home(), // This is your home page
        '/login': (context) => const LoginPage(), // This is your login page
      },
    );
  }
}