import 'package:flutter/material.dart';
import 'package:goatsmart/pages/itemGallery.dart';
import 'package:goatsmart/pages/registerPage.dart';
import 'package:goatsmart/utils/auth.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = 'Login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 63, 85, 173),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: size.height,
            color: Color.fromARGB(255, 63, 85, 173),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', scale: 4),
                const Center(
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade100),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      prefixIcon: Icon(
                        Icons.account_circle_outlined,
                        color: Colors.blue.shade100,
                      ),
                      labelText: 'User',
                      labelStyle: const TextStyle(fontSize: 13),
                      hintText: 'ejemplo@gmail.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade100),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      prefixIcon: Icon(
                        Icons.account_circle_outlined,
                        color: Colors.black,
                      ),
                      labelText: 'Password',
                      labelStyle: const TextStyle(fontSize: 13),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  ),
                  onPressed: () async {
                    String email = _emailController.text;
                    String password = _passwordController.text;
                    if (email.isNotEmpty && password.isNotEmpty) {
                      dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                      if (result != null) {
                        print('Logged in');
                        Navigator.popAndPushNamed(context, ItemGallery.routeName);
                      } else {
                        print('Error logging in');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error logging in')));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter email and password')));
                    }
                  },
                  child: const Text('Login', style: TextStyle(fontSize: 20)),
                ),
                SizedBox(height: size.height * 0.1),
                GestureDetector(
                  onTap: () => Navigator.popAndPushNamed(context, RegisterPage.routeName),
                  child: Text('Don\'t have an account?', style: TextStyle(color: Colors.blue.shade100)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
