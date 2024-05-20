import 'dart:async';

import 'package:flutter/material.dart';
import 'package:goatsmart/models/user.dart';
import 'package:goatsmart/pages/home.dart';
import 'package:goatsmart/pages/ProfileEdit.dart';
import 'package:goatsmart/pages/Profile.dart';
import 'package:goatsmart/pages/geolocalization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';

class UserProfile extends StatefulWidget {
  final User user;

  const UserProfile({Key? key, required this.user}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late User _user;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('No internet connection'),
            duration: Duration(seconds: 10),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 9, 4, 83),
              ),
            ),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          width: 7,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(_user.imageUrl),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 37,
                        height: 37,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 255, 180, 68), // Color de fondo del botón editar
                        ),
                        child: IconButton(
                          icon: Icon(Icons.edit),
                          iconSize: 23,
                          color: Colors.white,
                          onPressed: () async {
                            final updatedUser = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileEdit(user: _user),
                              ),
                            );
                            if (updatedUser != null) {
                              setState(() {
                                _user = updatedUser as User;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '${_user.username}!',
                      style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 60),
            buildButtonWithIcon(
              'Profile',
              Icons.arrow_forward_ios,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile(user: _user),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            buildButtonWithIcon(
              'Location',
              Icons.arrow_forward_ios,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationPage(),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            buildButtonWithIcon(
              'Create offer',
              Icons.arrow_forward_ios,
              () {
                // Add navigation logic for Create offer
              },
            ),
            SizedBox(height: 20),
            buildButtonWithIcon(
              'My Reviews',
              Icons.arrow_forward_ios,
              () {
                // Add navigation logic for My Reviews
              },
            ),
            SizedBox(height: 20),
            buildButtonWithIcon(
              'Terms and Conditions',
              Icons.arrow_forward_ios,
              () {
                // Add navigation logic for Terms and Conditions
              },
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 180, 68),
                      minimumSize: Size(400, 50),
                    ),
                    child: Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButtonWithIcon(String text, IconData icon, VoidCallback onPressed) {
    return Stack(
      children: [
        TextButton(
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: TextStyle(fontSize: 24, color: Colors.black),
              ),
              Icon(
                icon,
                color: Colors.black,
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: -1,
          child: Container(
            height: 1.5,
            color: const Color.fromARGB(255, 182, 181, 181),
          ),
        ),
      ],
    );
  }
}
