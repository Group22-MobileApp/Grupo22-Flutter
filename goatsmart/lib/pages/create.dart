import 'package:flutter/material.dart';
import 'package:goatsmart/pages/home.dart';
import 'package:goatsmart/pages/itemGallery.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:goatsmart/services/firebase_auth_service.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({Key? key}) : super(key: key);
  @override
  State<CreatePage> createState() => CreatePageState();
}

class CreatePageState extends State<CreatePage> {
  static const routeName = 'registerPage';

  final AuthService _auth = AuthService();

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController carrerController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController numberPhone = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    carrerController.dispose();
    idController.dispose();
    numberPhone.dispose();
    super.dispose();
  }

  void signUp() async {
    String? user = await _auth.signUpWithEmailAndPassword(
        emailController.text, passwordController.text);

    if (user != null) {
      print("User created successfully");
      Navigator.push( context, MaterialPageRoute(builder: (context) => const CreatePage()));
    } else {
      print("User not created");
    }

  }

  
  // View Model ------------------------------------------------------------
  
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
            image: AssetImage('assets/images/registration_background.png'),
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
                  'Create Account',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 242, 242, 242),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person),
                  hintText: 'Full name',
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
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 242, 242, 242),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.password),
                  hintText: 'Password',
                ),
              ),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 242, 242, 242),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.password),
                  hintText: 'Confirm password',
                ),
              ),
              InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  print('Phone number: ${number.phoneNumber}');
                },
                onInputValidated: (bool value) {
                  print('Valid: $value');
                },
                selectorConfig: SelectorConfig(
                  selectorType: PhoneInputSelectorType.DIALOG,
                ),
                ignoreBlank: false,
                autoValidateMode: AutovalidateMode.disabled,
                selectorTextStyle: const TextStyle(color: Colors.black),
                initialValue: PhoneNumber(isoCode: 'US'),
              ),
              TextField(
                controller: carrerController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 242, 242, 242),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.engineering),
                  hintText: 'What´s your carrer?',
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  //addUser(emailController.text, nameController.text,passwordController.text, carrerController.text, numberPhone.text);
                  signUp();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ItemGallery(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 117, 117, 117),
                  backgroundColor: const Color(0xffF7DC6F),
                  minimumSize: const Size(150, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Guardar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const HomePage())),
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 117, 117, 117),
                ),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
