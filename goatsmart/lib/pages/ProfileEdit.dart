import 'package:flutter/material.dart';
import 'package:goatsmart/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEdit extends StatelessWidget {
  final User user;

  const ProfileEdit({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                'Edit your profile',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            ProfilePhoto(imageUrl: user.imageUrl),
            SizedBox(height: 40.0),
            ProfileForm(user: user),
          ],
        ),
      ),
    );
  }
}

class ProfilePhoto extends StatelessWidget {
  final String imageUrl;

  const ProfilePhoto({Key? key, required this.imageUrl}) : super(key: key);

  Future<void> _showImagePickerDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Cambiar foto de perfil'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('Tomar foto'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
                    // Aquí puedes manejar la imagen tomada
                    if (pickedImage != null) {
                      // Agrega aquí la lógica para manejar la imagen tomada
                    }
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    child: Text('Seleccionar de la galería'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                      // Aquí puedes manejar la imagen seleccionada
                      if (pickedImage != null) {
                        // Agrega aquí la lógica para manejar la imagen seleccionada
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  width: 7.0,
                ),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(imageUrl),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 37.0,
                height: 37.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 255, 180, 68),
                ),
                child: IconButton(
                  onPressed: () => _showImagePickerDialog(context),
                  iconSize: 23.0,
                  icon: Icon(
                    Icons.camera_alt,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 20.0),
      ],
    );
  }
}

class ProfileForm extends StatefulWidget {
  final User user;

  ProfileForm({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  String _username = '';
  String _email = '';
  String _password = '';
  String _career = '';
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    _username = widget.user.username;
    _email = widget.user.email;
    _password = widget.user.password;
    _career = widget.user.carrer;
    _imageUrl = widget.user.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Username', _username),
        SizedBox(height: 20.0),
        _buildTextField('Email', _email),
        SizedBox(height: 20.0),
        _buildTextField('Password', '********', isPassword: true),
        SizedBox(height: 20.0),
        _buildTextField('Career', _career),
        SizedBox(height: 20.0),
        SizedBox(
          width: double.infinity,
          height: 50.0,
          child: ElevatedButton(
            onPressed: () {
              _saveChanges(widget.user); // Llama a la función para guardar los cambios
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 255, 180, 68), // Cambia el color de fondo del botón
              textStyle: TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 255, 255, 255)), // Ajusta el tamaño del texto del botón
            ),
            child: Text('Save Changes', style: TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 255, 255, 255))), // Ajusta el tamaño del texto del botón
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String initialValue, {bool isPassword = false}) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        if (label == 'Username') {
          setState(() {
            _username = value;
          });
        } else if (label == 'Email') {
          setState(() {
            _email = value;
          });
        } else if (label == 'Password') {
          setState(() {
            _password = value;
          });
        } else if (label == 'Career') {
          setState(() {
            _career = value;
          });
        }
      },
      obscureText: isPassword,
    );
  }

  void _saveChanges(User user) async {
  try {
    // Realiza una consulta para obtener el ID del documento asociado al usuario
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Users').where('id', isEqualTo: user.id).get();

    // Verifica si se encontró algún documento
    if (querySnapshot.docs.isNotEmpty) {
      String documentId = querySnapshot.docs.first.id;

      User updatedUser = User(
        id: user.id, // Asume que el ID se obtiene de la consulta
        username: _username,
        email: _email,
        password: _password, // Considerar hashing antes de guardar
        carrer: _career,
        imageUrl: _imageUrl, // Actualiza la URL de la imagen con la nueva URL
        name: user.name,
        number: user.number,
      );

      // Actualiza la información del usuario en Firestore
      await FirebaseFirestore.instance.collection('Users').doc(documentId).update(updatedUser.toMap());

      print('Changes saved successfully!');
    } else {
      print('User document not found.');
    }
  } catch (error) {
    print('Failed to save changes: $error');
  }
}

}