import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:goatsmart/models/user.dart' as LocalUser;
import 'package:image_picker/image_picker.dart';

class ProfileEdit extends StatefulWidget {
  final LocalUser.User user;

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
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('No internet connection'),
            duration: Duration(seconds: 10),
          ),
        );
      }
    });
    if (widget.user.imageUrl.isNotEmpty) {
      _imageFile = File(widget.user.imageUrl);
    }
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
            ProfilePhoto(imageFile: _imageFile, imageUrl: widget.user.imageUrl, onImagePicked: _pickImage),
            SizedBox(height: 40.0),
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
          title: Text('Change profile photo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('Take photo'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await onImagePicked(ImageSource.camera);
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    child: Text('Select from gallery'),
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
  final LocalUser.User user;
  final File? imageFile;

  ProfileForm({Key? key, required this.user, required this.imageFile}) : super(key: key);

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  String _username = '';
  String _email = '';
  String _password = '';
  String _career = '';

  @override
  void initState() {
    super.initState();
    _username = widget.user.username;
    _email = widget.user.email;
    _password = widget.user.password;
    _career = widget.user.carrer;
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
              _saveChanges(widget.user, widget.imageFile);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 255, 180, 68),
              textStyle: TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 255, 255, 255)),
            ),
            child: Text('Save Changes', style: TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 255, 255, 255))),
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
        setState(() {
          if (label == 'Username') {
            _username = value;
          } else if (label == 'Email') {
            _email = value;
          } else if (label == 'Password') {
            _password = value;
          } else if (label == 'Career') {
            _career = value;
          }
        });
      },
      obscureText: isPassword,
    );
  }

  void _saveChanges(LocalUser.User user, File? imageFile) async {
    try {
      String imageUrl = await user.updateImageUrl(imageFile);
      
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Users').where('id', isEqualTo: user.id).get();
      if (querySnapshot.docs.isNotEmpty) {
        String documentId = querySnapshot.docs.first.id;
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('Users').doc(documentId).get();
        List<dynamic> likedCategories = userSnapshot.get('likedCategories');
        List<dynamic> likedItems = userSnapshot.get('likedItems');

        LocalUser.User updatedUser = LocalUser.User(
          id: user.id,
          username: _username,
          email: _email,
          password: _password,
          carrer: _career,
          imageUrl: imageUrl,
          name: user.name,
          number: user.number,
          likedCategories: likedCategories.cast<String>(),
          likedItems: likedItems.cast<String>(),
        );

        await FirebaseFirestore.instance.collection('Users').doc(documentId).update(updatedUser.toMap());

        if (_email != user.email) {
          await FirebaseAuth.instance.currentUser?.updateEmail(_email);
        }

        if (_password != user.password) {
          await FirebaseAuth.instance.currentUser?.updatePassword(_password);
        }

        Navigator.pop(context, updatedUser);
        print('Changes saved successfully!');
      } else {
        print('User document not found.');
      }
    } catch (error) {
      print('Failed to save changes: $error');
    }
  }
}