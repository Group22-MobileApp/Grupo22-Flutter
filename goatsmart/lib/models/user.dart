import 'package:goatsmart/services/firebase_service.dart';

class User {
  final String carrer;
  final String email;
  final String username;
  final String password;
  final String id;
  final String number;
  final String imageUrl;
  final String name;
  final List<String> likedCategories;
  final List<String> likedItems; 

  User({
    required this.carrer,
    required this.email,
    required this.username,
    required this.password,
    required this.id,
    required this.number,
    required this.imageUrl,
    required this.name,
    required this.likedCategories,
    required this.likedItems, 
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
      'likedCategories': likedCategories,
      'likedItems': likedItems, 
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
      likedCategories: List<String>.from(map['likedCategories']),
      likedItems: List<String>.from(map['likedItems']), 
    );
  }

  Future<void> likeItem(String itemId) async {
    try {
      final FirebaseService firebaseService = FirebaseService(); 
      await firebaseService.likeItem(id, itemId);
    } catch (e) {
      print(e);
    }
  }

  Future<void> unlikeItem(String itemId) async {
    try {
      final FirebaseService firebaseService = FirebaseService(); 
      await firebaseService.unlikeItem(id, itemId);
    } catch (e) {
      print(e);
    }
  }
}
