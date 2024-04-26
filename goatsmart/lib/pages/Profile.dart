import 'package:flutter/material.dart';
import 'package:goatsmart/models/user.dart';
import 'package:goatsmart/pages/addMaterial.dart';
import 'package:goatsmart/pages/itemGallery.dart';
import 'package:goatsmart/pages/userProfile.dart';

class Profile extends StatefulWidget {
  final User user;

  const Profile({Key? key, required this.user}) : super(key: key);

  @override
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
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const LikeItemsView()));
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

    return Scaffold(
      backgroundColor: Colors.white, // Cambiar el color de fondo a blanco
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Alinear elementos hacia arriba a la izquierda
          children: [
            const SizedBox(height: 20), // Espacio antes de la palabra "Profile"
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat', // Cambiar el tipo de letra a Montserrat
                color: Colors.blue[900], // Cambiar el color a azul oscuro
              ),
            ),
            Row(
              children: [
                // Contenedor para la imagen del usuario
                SizedBox(
                  width: 120, // Ajustar el tamaño del contenedor
                  height: 120, // Ajustar el tamaño del contenedor
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(user.imageUrl),
                  ),
                ),
                const Spacer(), // Espaciador para ocupar el espacio restante
                // Columna para la calificación y sistema de estrellas
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Calificación
                    Text(
                      rating.toString(),
                      style: const TextStyle(
                        fontSize: 32, // Aumentar el tamaño de la fuente
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Sistema de estrellas con tamaño ajustado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          size: 36, // Ajustar el tamaño de la estrella
                          color: index < starCount ? Colors.yellow : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
            Text(
              'Reviews about me:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat', // Cambiar el tipo de letra a Montserrat
                color: Colors.blue[900], // Cambiar el color a azul oscuro
              ),
            ),
            const SizedBox(height: 10), // Espacio entre el título y las reviews
            // Ejemplo estático de una review
            _buildReview(
              'https://via.placeholder.com/150', // URL de la imagen del revisor (ficticio)
              'John Doe', // Nombre del revisor (ficticio)
              4, // Cantidad de estrellas (ficticio)
              'Great user!', // Comentario (ficticio)
            ),
            _buildReview(
              'https://via.placeholder.com/150', // URL de la imagen del revisor (ficticio)
              'Jane Smith', // Nombre del revisor (ficticio)
              5, // Cantidad de estrellas (ficticio)
              'Excellent user!', // Comentario (ficticio)
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
          // Imagen del revisor
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(width: 10), // Espacio entre la imagen y el nombre
          // Columna para el nombre del revisor y la cantidad de estrellas
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre del revisor
              Text(
                reviewerName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              // Cantidad de estrellas
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