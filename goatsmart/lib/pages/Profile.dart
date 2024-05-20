import 'dart:async';
import 'package:flutter/material.dart';
import 'package:goatsmart/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';

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

  @override
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
  _fetchUserData(); // Llama al método para obtener la información actualizada del usuario
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
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(_user.imageUrl),
                  ),
                ),
                SizedBox(width: 50),
                Column(
                  children: [
                    Text(
                      _averageRating.toStringAsFixed(1),
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          size: 35,
                          color: index < 4 ? Colors.yellow : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_user.username}',
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  '${_user.email}',
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  '${_user.carrer}',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(
              thickness: 2,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              'Reviews about me:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 10),
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
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reviewerName,
                style: TextStyle(
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
              SizedBox(height: 5),
              Text(
                comment,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
