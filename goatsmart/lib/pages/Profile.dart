import 'dart:async';
import 'package:flutter/material.dart';
import 'package:goatsmart/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
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
  _ProfileState createState() => _ProfileState(user);
}

class _ProfileState extends State<Profile> {
  int _selectedIndex = 0;
  
  User user;

  _ProfileState(this.user);

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const ItemGallery()));
      } else if (index == 1) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LikedItemsGallery()));
      } else if (index == 2) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddMaterialItemView(userLoggedIn: user)));                              
      } else if (index == 3) {
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatView()));
      } else if (index == 4) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserProfile(user: widget.user)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Valor estático para la calificación
    double rating = 4.2;
    // Valor estático para la cantidad de estrellas
    int starCount = 4;


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
            const SizedBox(height: 20), // Espacio antes de la palabra "Profile"
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
                // Contenedor para la imagen del usuario
                SizedBox(
                  width: 120, // Ajustar el tamaño del contenedor
                  height: 120, // Ajustar el tamaño del contenedor
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(_user.imageUrl),
                  ),
                ),
                SizedBox(width: 50),
                const Spacer(), // Espaciador para ocupar el espacio restante
                // Columna para la calificación y sistema de estrellas
                Column(
                  children: [
                    Text(
                      _averageRating.toStringAsFixed(1),
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      rating.toString(),
                      style: const TextStyle(
                        fontSize: 32, // Aumentar el tamaño de la fuente
                        fontWeight: FontWeight.bold,
                      ),
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
            const SizedBox(height: 20),
            Text(
              user.username,
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              user.email,
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              user.carrer,
              style: const TextStyle(fontSize: 20),
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
            const SizedBox(height: 10), // Espacio entre el título y las reviews
            // Ejemplo estático de una review
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
        //BackgroundColor white and selected item color orange and black font
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
  
  // Método para construir una review
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
          const SizedBox(width: 10), // Espacio entre la imagen y el nombre
          // Columna para el nombre del revisor y la cantidad de estrellas
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
              SizedBox(height: 5),
              // Comentario
              const SizedBox(height: 5), // Espacio entre las estrellas y el comentario
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
