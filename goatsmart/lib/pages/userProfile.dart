import 'package:flutter/material.dart';
import 'package:goatsmart/models/user.dart';

class UserProfile extends StatefulWidget {
  final User user;

  const UserProfile({Key? key, required this.user}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _careerController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _careerController = TextEditingController(text: widget.user.carrer);
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
        title: Text('User Profile'),
        actions: _buildEditButtons(), // Mostrar botones de edición
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Alinear elementos hacia arriba a la izquierda
          children: [
            SizedBox(height: 20), // Espacio antes de la palabra "Profile"
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
                Container(
                  width: 120, // Ajustar el tamaño del contenedor
                  height: 120, // Ajustar el tamaño del contenedor
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(widget.user.imageUrl),
                  ),
                ),
                Spacer(), // Espaciador para ocupar el espacio restante
                // Columna para la calificación y sistema de estrellas
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Calificación
                    Text(
                      rating.toString(),
                      style: TextStyle(
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
            SizedBox(height: 20),
            _buildEditableTextFormField(
              controller: _usernameController,
              labelText: 'Username',
              isEditing: _isEditing,
            ),
            _buildEditableTextFormField(
              controller: _emailController,
              labelText: 'Email',
              isEditing: _isEditing,
            ),
            _buildEditableTextFormField(
              controller: _careerController,
              labelText: 'Career',
              isEditing: _isEditing,
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

  List<Widget> _buildEditButtons() {
    if (_isEditing) {
      return [
        TextButton(
          onPressed: () {
            setState(() {
              _isEditing = false;
            });
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Guardar cambios
            _saveChanges();
          },
          child: Text('Save'),
        ),
      ];
    } else {
      return [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            setState(() {
              _isEditing = true;
            });
          },
        ),
      ];
    }
  }

  void _saveChanges() {
    // Aquí puedes agregar la lógica para guardar los cambios
    setState(() {
      _isEditing = false;
    });
  }

Widget _buildEditableTextFormField({
  required TextEditingController controller,
  required String labelText,
  required bool isEditing,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: isEditing ? labelText : null, // Ocultar la etiqueta cuando no está en modo de edición
      floatingLabelBehavior: isEditing ? FloatingLabelBehavior.always : FloatingLabelBehavior.never, // Ocultar la etiqueta cuando no está en modo de edición
      border: isEditing ? OutlineInputBorder() : InputBorder.none, // Añadir un borde alrededor del campo de texto solo cuando está en modo de edición
      filled: true, // Rellenar el campo de texto con un color
      fillColor: isEditing ? Colors.white : Colors.transparent, // Cambiar el color de fondo del campo de texto a transparente cuando no está en modo de edición
      labelStyle: TextStyle(
        color: Colors.blue[900], // Cambiar el color del texto de la etiqueta
      ),
    ),
    style: TextStyle(
      color: Colors.black, // Cambiar el color del texto del campo de texto
      fontSize: 16, // Ajustar el tamaño de la letra
    ),
    enabled: isEditing,
  );
}

}