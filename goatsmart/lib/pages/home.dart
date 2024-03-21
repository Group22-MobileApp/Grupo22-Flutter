import 'dart:html';

import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  ElevatedButton buildLoginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/login');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFF7DC6F),
        foregroundColor: Color(0xFF2E4053),
        disabledBackgroundColor: Color(0xFF2E4053),
        disabledForegroundColor: Color(0xFF2E4053),
        shadowColor: Color(0xFF2E4053),
        elevation: 4,
        textStyle: TextStyle(
          fontSize: 30,          
          fontFamily: 'Montserrat',
        
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ), 
      minimumSize: Size(400, 60),
      ),
      child: Text('Let’s get started'),
    );
  }
    

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      // White background
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Image
            Image(
              image: AssetImage('assets/images/logo.png'),
              height: 200,              
            ),
            Text(
              'GOAT’S MART',
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                fontFamily: 'Raleway',
                // fontColor: Color(0xFF2E4053)
                color: Color(0xFF2E4053),                
              ),
            ),
            Text(
              'Uniandes store by students for students',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                // fontColor: Color(0xFF2E4053)
                color: Color(0xFF2E4053),
            )
            ),
            // Padding
            Padding(
              padding: EdgeInsets.only(top: 100),
            ),
            buildLoginButton(context),
            Padding(
              padding: EdgeInsets.only(top: 20),
            ),            
            TextButton(
              onPressed: () => MessageEvent('Login'),
              style: TextButton.styleFrom(
                primary: Color.fromARGB(255, 117, 117, 117),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'I already have an account',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_outlined,                    
                    color: Color.fromARGB(255, 255, 170, 0), 
                  ),
                ],
              ),
            ),                      
          ],
        ),
      ),
    );
  }
}
                            