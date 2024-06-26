import 'dart:async';
import 'package:flutter/material.dart';
import 'package:goatsmart/models/user.dart';
import 'package:goatsmart/pages/addMaterial.dart';
import 'package:goatsmart/pages/home.dart';
import 'package:goatsmart/pages/itemGallery.dart';
import 'package:goatsmart/pages/ProfileEdit.dart';
import 'package:goatsmart/pages/Profile.dart';
import 'package:goatsmart/pages/geolocalization.dart';
import 'package:goatsmart/pages/likedItems.dart';
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
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _user = widget.user;

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('No internet connection'),
            duration: Duration(seconds: 2),
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

Future<bool> _checkConnectivity() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    return false;
  }
  return true;
}

void _onItemTapped(int index) async {
  bool isConnected = await _checkConnectivity();
  if (!isConnected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'No Internet Connection',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: const Text('Please check your internet connection and try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    return;
  }

  setState(() {
    _selectedIndex = index;
    // Navegación basada en el índice seleccionado
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ItemGallery()));
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LikedItemsGallery()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AddMaterialItemView(userLoggedIn: _user)));
    } else if (index == 3) {
      // Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatView()));
    } else if (index == 4) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfile(user: _user)));
    }
  });
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 9, 4, 83),
              ),
            ),
            const SizedBox(height: 20),
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
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 255, 180, 68), // Color de fondo del botón editar
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit),
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
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hola',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '${_user.username}!',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
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
            const SizedBox(height: 20),
            buildButtonWithIcon(
              'Location',
              Icons.arrow_forward_ios,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LocationPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            buildButtonWithIcon(
              'Create offer',
              Icons.arrow_forward_ios,
              () {
                // Add navigation logic for Create offer
              },
            ),
            const SizedBox(height: 20),
            buildButtonWithIcon(
              'My Reviews',
              Icons.arrow_forward_ios,
              () {
                // Add navigation logic for My Reviews
              },
            ),
            const SizedBox(height: 20),
            buildButtonWithIcon(
              'Terms and Conditions',
              Icons.arrow_forward_ios,
              () {
                // Add navigation logic for Terms and Conditions
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const HomePage()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 180, 68),
                      minimumSize: const Size(400, 50),
                    ),
                    child: const Text(
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 0, 0, 0),
        unselectedItemColor: const Color.fromARGB(255, 138, 136, 136),
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Liked Items',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
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
                style: const TextStyle(fontSize: 24, color: Colors.black),
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
