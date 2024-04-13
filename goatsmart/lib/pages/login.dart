import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:goatsmart/pages/create.dart';
import 'package:goatsmart/pages/home.dart';
import 'package:goatsmart/pages/itemGallery.dart';
import 'package:goatsmart/services/firebase_auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Login Page'),
        ),
        body: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: AssetImage('assets/images/login_background.png'),
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Good to see you back!',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 242, 242, 242),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.email),
                    hintText: 'Uniandes email',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 242, 242, 242),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.password),
                    hintText: 'password',
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreatePage(),
                      ),
                    );
                  },
                  child: const Text('Go to CreatePage'),
                ),
                ElevatedButton(
                  onPressed: () {
                    signIn();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 117, 117, 117),
                    backgroundColor: Color(0xffF7DC6F),
                    minimumSize: Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Next'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Home())),
                  style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 117, 117, 117),
                      backgroundColor: Color(0xffffffff)),
                  child: const Text('cancel'),
                ),
              ],
            ),
          ),
        ));
  }

  void signIn() async {
    String email = emailController.text;
    String password = passwordController.text;
    print("Correo ingresado es: $email");
    print("Contraseña ingresada es: $password");
    User? user = await _auth.signInWithEmailAndPassword(
        emailController.text, passwordController.text);
    if (user != null) {
      print("User logged in successfully");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const ItemGallery()));
    } else {
      print("User not found");
    }
  }
}
