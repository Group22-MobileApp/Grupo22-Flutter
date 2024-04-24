import 'package:flutter/material.dart';
import 'package:goatsmart/pages/create.dart';
import 'package:goatsmart/pages/home.dart';
import 'package:goatsmart/pages/itemGallery.dart';
import 'package:goatsmart/services/firebase_auth_service.dart';
import 'package:goatsmart/services/control_features.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  static const routeName = 'LoginPage';

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();
  final ConnectionManager _controlFeatures = ConnectionManager();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool obscureText = false;

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
          decoration: const BoxDecoration(
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
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: const Text(
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
                    fillColor: const Color.fromARGB(255, 242, 242, 242),
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
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 242, 242, 242),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.password),
                    hintText: 'password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                    ),
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
                  child: const Text('I already have an account'),
                ),
                ElevatedButton(
                  onPressed: () {
                    signIn(emailController.text, passwordController.text);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 117, 117, 117),
                    backgroundColor: const Color(0xffF7DC6F),
                    minimumSize: const Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Log In'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage())),
                  style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 117, 117, 117),
                      backgroundColor: const Color(0xffffffff)),
                  child: const Text('cancel'),
                ),
              ],
            ),
          ),
        ));
  }

  void signIn(String email, String password) async {
    print("Correo ingresado es: $email");
    print("Contraseña ingresada es: $password");
    String? user = await _auth.signInWithEmailAndPassword(
      email,
      password,
    );
    if (user != null) {
      print("User logged in successfully");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ItemGallery()),
      );
    } else {
      if (email.isEmpty || password.isEmpty) {
        print("Email or password is empty");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email or password is empty')),
        );
        return;
      }
      if (email.contains('@') == false) {
        print("Email is not valid");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email is not valid')),
        );
        return;
      }
      if ( !await _controlFeatures.checkInternetConnection()) {
        print("Internet is not connected");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('No Network Connection! '),
              backgroundColor: Colors.white,
              content: Text('No hay conexion a internet, por favor revisa tu red e intenta nuevamente.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en la Autenticación, comprueba tus credenciales e intenta nuevamente')),
        );
      }
    }
  }
}
