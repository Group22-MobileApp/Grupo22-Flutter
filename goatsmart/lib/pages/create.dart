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
  TextEditingController numberPhone = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    carrerController.dispose();
    numberPhone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
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
                  // Update the phone number controller
                  numberPhone.text = number.phoneNumber ?? '';
                },
                onInputValidated: (bool value) {
                  print('Valid: $value');
                },
                selectorConfig: const SelectorConfig(
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
                onPressed: signUp,
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 117, 117, 117),
                  backgroundColor: const Color(0xffF7DC6F),
                  minimumSize: const Size(150, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Save'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 117, 117, 117),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void signUp() async {
    String email = emailController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    String name = nameController.text;
    String carrer = carrerController.text;
    String phoneNumber = numberPhone.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (email.isEmpty || password.isEmpty || name.isEmpty || carrer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in at least all fields except phone number')),
      );
      return;
    }

    // More validations
    if (!email.contains('@uniandes.edu.co')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please use a Uniandes email')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    if (phoneNumber.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    if (carrer.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Carrer must be at least 3 characters')),
      );
      return;
    }    

    String? user = await _auth.signUpWithEmailAndPassword(email, password);

    if (user != null) {
      print("User created successfully");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ItemGallery()),
      );
    } else {
      print("User not created");
    }
  }
}
