import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:async';

import 'package:goatsmart/models/user.dart';
import 'package:goatsmart/pages/addMaterial.dart';
import 'package:goatsmart/pages/itemGallery.dart';
import 'package:goatsmart/pages/likedItems.dart';
import 'package:goatsmart/pages/userProfile.dart';

class Profile extends StatefulWidget {
  final User user;

  const Profile({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late User _user;
  final double _averageRating = 4.2;
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
    _fetchUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchUserData();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Users').where('id', isEqualTo: _user.id).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userData = querySnapshot.docs.first;
        User updatedUser = User.fromMap(userData.data() as Map<String, dynamic>);
        setState(() {
          _user = updatedUser;
        });
      } else {
        print('No user data found in Firestore.');
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
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
            const SizedBox(height: 20),
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                color: Colors.blue[900],
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(_user.imageUrl),
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          size: 36,
                          color: index < 4 ? Colors.yellow : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _user.username,
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              _user.email,
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              _user.carrer,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            const Divider(
              thickness: 2,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              'Reviews about me:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 10),
            _buildReview(
              'https://via.placeholder.com/150',
              'John Doe',
              4,
              'Great user!',
            ),
            _buildReview(
              'https://via.placeholder.com/150',
              'Jane Smith',
              5,
              'Excellent user!',
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

  Widget _buildReview(String imageUrl, String reviewerName, int starCount, String comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reviewerName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    size: 22,
                    color: index < starCount ? Colors.yellow : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                comment,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}