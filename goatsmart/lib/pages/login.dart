import 'package:flutter/material.dart';

import 'package:goatsmart/pages/home.dart';

import 'package:firebase_core/firebase_core.dart';

class login extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GOAT´S MART',
      home: Scaffold(
        appBar: AppBar(
          title: Text('GOAT´S MART'),
        ),
        body: LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';

  void _submitForm() async {
 
}
    
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Login', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            Text('Good to see you back!', style: TextStyle(fontSize: 18)),
            SizedBox(height: 24),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Uniandes email',
              ),
              onChanged: (value) {
                setState(() {
                  _email = value;
                });
              },
              validator: (value) {
                // if (value.isEmpty) {
                //   return 'Please enter your email';
                // }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Password',
             ),
              onChanged: (value) {
                setState(() {
                  _password = value;
                });
              },
              validator: (value) {
                // if (value.isEmpty) {
                //   return 'Please enter your password';
                // }
                return null;
              },
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Log in'),
            ),
          ],
        ),
      ),
    );
  }
}