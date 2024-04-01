import 'package:flutter/material.dart';
import 'package:goatsmart/pages/itemGallery.dart';
import 'package:goatsmart/pages/registerPage.dart';

class LoginPage extends StatelessWidget {
  static const String routeName = 'Login';
  const LoginPage({super.key});

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
            color : Color.fromARGB(255, 63, 85, 173),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', scale: 4),
                const Center(child: Text('Login', style: TextStyle(color: Colors.white, fontSize: 30),),),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue.shade100),
                        borderRadius: BorderRadius.circular(50)),
                      prefixIcon: Icon(
                        Icons.account_circle_outlined,
                        color: Colors.blue.shade100,
                      ),
                      labelText: 'User',
                      labelStyle: const TextStyle(fontSize: 13),
                      hintText: 'ejemplo@gmail.com'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue.shade100,),
                        borderRadius: BorderRadius.circular(50)),
                      prefixIcon: Icon(
                        Icons.account_circle_outlined,
                        color: Colors.black,
                      ),
                      labelText: 'Password',
                      labelStyle: const TextStyle(fontSize: 13)     
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
                  onPressed: () {
                    Navigator.popAndPushNamed(context, ItemGallery.routeName);
                  },
                  child: const Text('Login', style: TextStyle(fontSize: 20),),
                ),
                SizedBox(height: size.height*0.1,),
                GestureDetector(
                  onTap: () => Navigator.popAndPushNamed(context, RegisterPage.routename),
                  child: Text('Don\'t have an account?', style: TextStyle(color: Colors.blue.shade100),),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}                