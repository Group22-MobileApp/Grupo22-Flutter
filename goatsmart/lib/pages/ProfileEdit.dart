import 'dart:async';
import 'package:flutter/material.dart';
import 'package:goatsmart/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileEdit extends StatefulWidget {
  final User user;

  const ProfileEdit({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                'Edit your profile',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            ProfilePhoto(imageFile: _imageFile, imageUrl: widget.user.imageUrl, onImagePicked: _pickImage),
            const SizedBox(height: 40.0),
            ProfileForm(user: widget.user, imageFile: _imageFile),
          ],
        ),
      ),
    );
  }
}

class ProfilePhoto extends StatelessWidget {
  final File? imageFile;
  final String imageUrl;
  final Future<void> Function(ImageSource source) onImagePicked;

  const ProfilePhoto({Key? key, required this.imageFile, required this.imageUrl, required this.onImagePicked}) : super(key: key);

  Future<void> _showImagePickerDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Change profile photo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Take photo'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await onImagePicked(ImageSource.camera);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    child: const Text('Select from gallery'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await onImagePicked(ImageSource.gallery);
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
                backgroundImage: imageFile != null ? FileImage(imageFile!) : NetworkImage(imageUrl) as ImageProvider,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 37.0,
                height: 37.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 255, 180, 68),
                ),
                child: IconButton(
                  onPressed: () => _showImagePickerDialog(context),
                  iconSize: 23.0,
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 20.0),
      ],
    );
  }
}

class ProfileForm extends StatefulWidget {
  final User user;
  final File? imageFile;

  const ProfileForm({Key? key, required this.user, required this.imageFile}) : super(key: key);

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late String _username;
  late String _email;
  late String _password;
  late String _career;
  late String _imageUrl;

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
        const SizedBox(height: 20.0),
        _buildTextField('Email', _email),
        const SizedBox(height: 20.0),
        _buildTextField('Password', '********', isPassword: true),
        const SizedBox(height: 20.0),
        _buildTextField('Career', _career),
        const SizedBox(height: 20.0),
        SizedBox(
          width: double.infinity,
          height: 50.0,
          child: ElevatedButton(
            onPressed: () {
              _saveChanges(widget.user); // Llama a la función para guardar los cambios
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 180, 68), // Cambia el color de fondo del botón
              textStyle: const TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 255, 255, 255)), // Ajusta el tamaño del texto del botón
            ),
            child: const Text('Save Changes', style: TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 255, 255, 255))), // Ajusta el tamaño del texto del botón
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
        border: const OutlineInputBorder(),
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
        String docId = querySnapshot.docs.first.id;

        // Crea un mapa con los datos actualizados del usuario
        Map<String, dynamic> updatedData = {
          'username': _username,
          'email': _email,
          'password': _password,
          'career': _career,
        };

        // Si hay una imagen seleccionada, súbela a Firebase Storage y agrega la URL al mapa
        if (widget.imageFile != null) {
          // Aquí puedes agregar el código para subir la imagen a Firebase Storage y obtener la URL
          // String imageUrl = await uploadImageToFirebase(widget.imageFile!);
          // updatedData['imageUrl'] = imageUrl;
        }

        // Actualiza el documento en Firestore con los datos actualizados
        await FirebaseFirestore.instance.collection('Users').doc(docId).update(updatedData);

        // Muestra un mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Profile updated successfully'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      // Muestra un mensaje de error en caso de que falle la actualización
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to update profile'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }
}
