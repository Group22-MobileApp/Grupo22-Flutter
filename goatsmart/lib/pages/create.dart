import 'dart:io';
import 'package:flutter/material.dart';
import 'package:goatsmart/models/user.dart';
import 'package:goatsmart/pages/home.dart';
import 'package:goatsmart/pages/itemGallery.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:goatsmart/services/firebase_auth_service.dart';
import 'package:goatsmart/services/firebase_service.dart';
import 'package:goatsmart/services/control_features.dart';
import 'package:image_picker/image_picker.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({Key? key}) : super(key: key);

  @override
  State<CreatePage> createState() => CreatePageState();

  static List<String> careers = [
    'ESTUDIOS DIRIGIDOS',
    'ADMINISTRACIÓN',
    'ECONOMÍA',
    'GOBIERNO Y ASUNTOS PÚBLICOS',
    'BIOLOGÍA',
    'FÍSICA',
    'GEOCIENCIAS',
    'MATEMÁTICAS',
    'MICROBIOLOGÍA',
    'QUÍMICA',
    'MEDICINA',
    'ARQUITECTURA',
    'ARTE',
    'DISEÑO',
    'HISTORIA DEL ARTE',
    'LITERATURA',
    'MÚSICA',
    'NARRATIVAS DIGITALES',
    'INGENIERÍA AMBIENTAL',
    'INGENIERÍA BIOMÉDICA',
    'INGENIERÍA CIVIL',
    'INGENIERÍA ELÉCTRICA',
    'INGENIERÍA ELECTRÓNICA',
    'INGENIERÍA INDUSTRIAL',
    'INGENIERÍA MECÁNICA',
    'INGENIERÍA QUÍMICA',
    'INGENIERÍA DE SISTEMAS Y COMPUTACIÓN',
    'DERECHO',
    'ANTROPOLOGÍA',
    'CIENCIA POLÍTICA',
    'ESTUDIOS GLOBALES',
    'FILOSOFÍA',
    'HISTORIA',
    'LENGUAS Y CULTURA',
    'PSICOLOGÍA',
    'LICENCIATURA EN ARTES',
    'LICENCIATURA EN BIOLOGÍA',
    'LICENCIATURA EN EDUCACIÓN INFANTIL',
    'LICENCIATURA EN ESPAÑOL Y FILOLOGÍA',
    'LICENCIATURA EN FILOSOFÍA',
    'LICENCIATURA EN FÍSICA',
    'LICENCIATURA EN HISTORIA',
    'LICENCIATURA EN MATEMÁTICAS',
    'LICENCIATURA EN QUÍMICA',
  ];
}

class CreatePageState extends State<CreatePage> {
  static const routeName = 'registerPage';

  String? selectedCareer = 'INGENIERÍA DE SISTEMAS Y COMPUTACIÓN';

  final AuthService _auth = AuthService();
  final FirebaseService _firebaseService = FirebaseService();
  final ConnectionManager _controlFeatures = ConnectionManager();
  final ImagePicker _imagePicker = ImagePicker();

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController carrerController = TextEditingController();
  TextEditingController numberPhone = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  File? _userImage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
          child: SingleChildScrollView(
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
                  maxLength: 20,
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
                TextField(
                  maxLength: 10,
                  controller: usernameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 242, 242, 242),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.person),
                    hintText: 'Username',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  maxLength: 15,
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 242, 242, 242),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.password),
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                TextField(
                  maxLength: 15,
                  controller: confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 242, 242, 242),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.password),
                    hintText: 'Confirm password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
                InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
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
                  initialValue: PhoneNumber(isoCode: 'CO'),
                ),
                DropdownButton<String>(
                  value: selectedCareer,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCareer = newValue!;
                    });
                  },
                  items: CreatePage.careers
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Pick Image'),
                ),
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _userImage != null ? FileImage(_userImage!) : null,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      ),
    );
  }

  void signUp() async {
    String email = emailController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    String name = nameController.text;
    String phoneNumber = numberPhone.text;
    String username = usernameController.text;

    if (selectedCareer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a career')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (email.isEmpty ||
        password.isEmpty ||
        name.isEmpty ||
        username.isEmpty ||
        phoneNumber.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

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

    if (phoneNumber.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    if (_userImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick an image')),
      );
      return;
    }

    bool conec = await _controlFeatures.checkInternetConnection();
    if(conec == false){
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('No Network Connection! '),
              backgroundColor: Colors.white,
              content: const Text('No hay conexion a internet, pero no te preocupes. Se continuara con el proceso cuando se restablezca la conexion.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );

      while (true) {
        bool conec = await _controlFeatures.checkInternetConnection();
        if (conec) {
          break;
        }
        await Future.delayed(const Duration(seconds: 1));
      }

    }

    String? userId = await _auth.signUpWithEmailAndPassword(email, password);

    if (userId != null) {
      print("User created successfully");

      String? imageUrl;
      if (_userImage != null) {
        imageUrl = await _firebaseService.uploadImage(_userImage!);
      }
      
      await _firebaseService.addUser(User(
        carrer: selectedCareer!,
        email: email,
        username: username,
        password: password,
        id: userId,
        number: phoneNumber,
        imageUrl: imageUrl ?? '',
        name: name,
        likedCategories: [],
        likedItems: [],
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Registration Successful',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ItemGallery()),
      );
    } else {
      print("User not created");
    }
  }


  void _pickImage() async {
    final imageSource = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Select Image Source'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text('Gallery'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text('Camera'),
            ),
          ],
        );
      },
    );

    if (imageSource != null) {
      final pickedImage = await _imagePicker.pickImage(source: imageSource);
      if (pickedImage != null) {
        setState(() {
          _userImage = File(pickedImage.path);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image picked successfully')),
        );
      }
    }
  }
}
