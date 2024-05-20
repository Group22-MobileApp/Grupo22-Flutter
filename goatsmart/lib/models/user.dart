import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class User {
  String carrer;
  String email;
  String username;
  String password;
  String id;
  String number;
  String imageUrl;
  String name;

  User({
    required this.carrer,
    required this.email,
    required this.username,
    required this.password,
    required this.id,
    required this.number,
    required this.imageUrl,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'carrer': carrer,
      'email': email,
      'username': username,
      'password': password,
      'id': id,
      'number': number,
      'imageUrl': imageUrl,
      'name': name,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      carrer: map['carrer'],
      email: map['email'],
      username: map['username'],
      password: map['password'],
      id: map['id'],
      number: map['number'],
      imageUrl: map['imageUrl'],
      name: map['name'],
    );
  }

  Future<void> updateUserInfo(User updatedUser) async {
    try {
      String documentId = await getDocumentId();
      await FirebaseFirestore.instance.collection('Users').doc(documentId).update(updatedUser.toMap());
      print('User information updated successfully!');
    } catch (error) {
      print('Failed to update user information: $error');
    }
  }

  Future<String> updateImageUrl(File? imageFile) async {
  try {
    if (imageFile != null) {
      final Reference ref = FirebaseStorage.instance.ref().child('user_profile_images').child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(imageFile);
      final String imageUrl = await ref.getDownloadURL();
      return imageUrl;
    }
    return imageUrl; // Si no se subió ninguna imagen nueva, se devuelve la URL actual
  } catch (error) {
    print('Failed to update image URL: $error');
    return ''; // En caso de error, se devuelve una cadena vacía
  }
}


  Future<String> getDocumentId() async {
    return 'document_id'; // Aquí debes implementar la lógica real para obtener el ID del documento
  }
}
