import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String carrer;
  final String email;
  final String username;
  final String password;
  final String id;
  final String number;
  final String imageUrl;
  final String name;

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
      // Realiza una consulta para obtener el ID del documento asociado al usuario
      // Suponiendo que tienes un método en tu clase User para obtener el ID del usuario
      String documentId = await getDocumentId();

      // Actualiza la información del usuario en Firestore
      await FirebaseFirestore.instance.collection('Users').doc(documentId).update(updatedUser.toMap());

      print('User information updated successfully!');
    } catch (error) {
      print('Failed to update user information: $error');
    }
  }

  Future<String> getDocumentId() async {
    // Aquí deberías tener la lógica para obtener el ID del documento asociado al usuario
    // Por ejemplo, si el ID del usuario se almacena en el campo 'id' de la colección 'Users'
    // Puedes hacer una consulta a Firestore para obtener el ID del documento basado en el 'id' del usuario
    // y luego devolver ese ID
    return 'document_id'; // Esta es una implementación de ejemplo, debes reemplazarla con tu lógica real
  }
}
