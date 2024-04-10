import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:goatsmart/pages/itemGallery.dart';
import 'package:goatsmart/pages/login.dart';
import 'package:goatsmart/utils/auth.dart';

class RegisterPage extends StatefulWidget{
  static const String routename = 'register';
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState()=> _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  final AuthService _auth = AuthService();


@override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 63, 85, 173),
      body: SafeArea(
        child: SingleChildScrollView(
          child: FormBuilder(
            key: _formKey,
            child: Container(
              width: double.infinity,
              height: size.height,
              color : Color.fromARGB(255, 63, 85, 173),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', scale: 4),
                  const Center(child: Text('Register', style: TextStyle(color: Colors.white, fontSize: 30),),),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FormBuilderTextField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      name: 'user',
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
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'User required'),
                        FormBuilderValidators.email(
                          errorText: 'Must enter valid email')
                      ]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FormBuilderTextField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      name: 'password',
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
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: 'Must enter password')
                    ]),
                  ),
                ),                                 
                botonRegister(context),
                SizedBox(height: size.height*0.1,),
                GestureDetector(
                  onTap: () => Navigator.popAndPushNamed(context, LoginPage.routeName),
                  child: Text('Already have an account?', style: TextStyle(color: Colors.blue.
                  shade100),),
                  )                
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ElevatedButton botonRegister (BuildContext context){
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      ),
      onPressed: () async {
        _formKey.currentState?.save();

        if (_formKey.currentState?.validate()==true){
          final v = _formKey.currentState?.value;          
          var result = await _auth.createAccount(
            v?['user'],
            v?['password']
          );

          if (result == 1){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('La contraseña es muy debil')));
          } else if (result == 2){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('El correo ya esta en uso')));
          } else if (result == 3){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('El correo no es valido')));
          } else {
            Navigator.popAndPushNamed(context, ItemGallery.routeName); 
          }

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, ingrese los datos')));
        }
      },
      child: const Text('Register', style: TextStyle(fontSize: 20),),
    );
  }
}
