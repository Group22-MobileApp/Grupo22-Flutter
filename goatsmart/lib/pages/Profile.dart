import 'package:flutter/material.dart';
import 'package:goatsmart/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {
  final User user;

  const Profile({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late User _user; // Cambiamos la declaración a 'late' para inicializar más adelante
  final double _averageRating = 4.2; // Calificación promedio (temporal)

  @override
  void initState() {
    super.initState();
    // Copiamos los datos del usuario recibido en el estado local
    _user = widget.user;
    _fetchUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Actualizamos los datos del usuario cada vez que la vista está a punto de mostrarse
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      // Realiza una consulta a Firebase Firestore para obtener los datos actualizados del usuario
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Users').where('id', isEqualTo: _user.id).get();

      // Verifica si se encontraron datos
      if (querySnapshot.docs.isNotEmpty) {
        // Extrae los datos del primer documento (ya que debería haber solo uno)
        DocumentSnapshot userData = querySnapshot.docs.first;

        // Construye un nuevo objeto User con los datos recuperados
        User updatedUser = User.fromMap(userData.data() as Map<String, dynamic>);

        // Actualiza el estado de la vista con los nuevos datos del usuario
        setState(() {
          _user = updatedUser;
        });
      } else {
        // Si no se encuentran datos, muestra un mensaje de error o maneja la situación según sea necesario
        print('No se encontraron datos del usuario en Firestore.');
      }
    } catch (error) {
      // Maneja los errores de la consulta a Firebase Firestore
      print('Error al obtener los datos del usuario: $error');
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
                fontFamily: 'Montserrat', // Cambiar el tipo de letra a Montserrat
                color: Colors.blue[900], // Cambiar el color a azul oscuro
              ),
            ),
            SizedBox(height: 20),
            // Contenedor para la imagen del usuario y calificación promedio
            Row(
              children: [
                // Contenedor para la imagen del usuario
                Container(
                  width: 120,
                  height: 120,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(_user.imageUrl),
                  ),
                ),
                SizedBox(width: 50),
                // Columna para la calificación promedio y estrellas
                Column(
                  children: [
                    // Texto de la calificación promedio
                    Text(
                      _averageRating.toStringAsFixed(1), // Muestra una sola cifra decimal
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    // Estrellas para representar la calificación promedio
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          size: 35, // Aumenta el tamaño de las estrellas
                          color: index < 4 ? Colors.yellow : Colors.grey, // Cambia a 4 estrellas
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            // Columna para la información del usuario
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
            // Separador entre la imagen del usuario y las revisiones
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
                fontFamily: 'Montserrat', // Cambiar el tipo de letra a Montserrat
                color: Colors.blue[900], // Cambiar el color a azul oscuro
              ),
            ),
            SizedBox(height: 10), // Espacio entre el título y las reviews
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
          SizedBox(width: 10), // Espacio entre la imagen y el nombre
          // Columna para el nombre del revisor y la cantidad de estrellas
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre del revisor
              Text(
                reviewerName,
                style: TextStyle(
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
              SizedBox(height: 5), // Espacio entre las estrellas y el comentario
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

