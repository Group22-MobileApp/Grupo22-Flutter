import 'package:flutter/material.dart';
import 'package:goatsmart/pages/login.dart';
import 'package:goatsmart/pages/itemGallery.dart';

class HomePage extends StatelessWidget {
  static const String routeName = 'HomePage';
  const HomePage({super.key});

  ElevatedButton buildLoginButton(BuildContext context) {
    return ElevatedButton(
    onPressed: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
    },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF7DC6F),
        foregroundColor: const Color(0xFF2E4053),
        disabledBackgroundColor: const Color(0xFF2E4053),
        disabledForegroundColor: const Color(0xFF2E4053),
        shadowColor: const Color(0xFF2E4053),
        elevation: 4,
        textStyle: const TextStyle(
          fontSize: 30,          
          fontFamily: 'Montserrat',
        
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ), 
      minimumSize: const Size(400, 60),
      ),
      child: const Text('Let’s get started'),
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
            const Image(
              image: AssetImage('assets/images/logo.png'),
              height: 200,              
            ),
            const Text(
              'GOAT’S MART',
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                fontFamily: 'Raleway',
                // fontColor: Color(0xFF2E4053)
                color: Color(0xFF2E4053),                
              ),
            ),
            const Text(
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
            const Padding(
              padding: EdgeInsets.only(top: 100),
            ),
            buildLoginButton(context),
            const Padding(
              padding: EdgeInsets.only(top: 20),
            ),            
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ItemGallery())),
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 117, 117, 117),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'I already have an account',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Montserrat',
                    ),
                  ),                  
                  const Padding(
                    padding: EdgeInsets.only(left: 20),
                  ),
                  FloatingActionButton(onPressed: null, 
                  backgroundColor: Color.fromARGB(230, 255, 168, 6), 
                  foregroundColor: Colors.white,
                  shape: CircleBorder(),
                    child: Icon(Icons.arrow_forward_outlined),
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
                            