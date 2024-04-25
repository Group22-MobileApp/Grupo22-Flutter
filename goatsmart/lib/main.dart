import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:goatsmart/firebase_options.dart';
import 'package:goatsmart/pages/home.dart';
import 'package:goatsmart/pages/login.dart';
import 'package:goatsmart/pages/itemGallery.dart';
import 'package:goatsmart/pages/create.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:goatsmart/services/firebase_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Lock the orientation to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          return MaterialApp(
            title: 'GoatSmart',
            theme: ThemeData(
              primaryColor: const Color(0xFF2E4053),
              colorScheme: ColorScheme.fromSwatch().copyWith(
                secondary: const Color(0xFFF7DC6F),
                tertiary: const Color(0xFFF5B041),
              ),
            ),
            home: const HomePage(),
            routes: {
              LoginPage.routeName: (context) => LoginPage(),
              HomePage.routeName: (context) => const HomePage(),
              ItemGallery.routeName: (context) => const ItemGallery(),
              CreatePageState.routeName: (context) => const CreatePage(),
            },
          );
        } else {
          return const MaterialApp(
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
