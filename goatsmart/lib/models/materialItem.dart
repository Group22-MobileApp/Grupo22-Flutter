import 'package:goatsmart/services/firebase_service.dart';

class MaterialItem {
  final String id;
  final String title;
  final String description;
  final double price;
  final List<String> images;
  final String owner;
  final String condition;
  final String interchangeable;
  int views;
  final List<String> categories;
  int likes;
  final List<String> likedBy;

  MaterialItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.owner,
    required this.condition,
    required this.interchangeable,
    required this.views,
    required this.categories,
    required this.likes,
    required this.likedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'images': images,
      'owner': owner,
      'condition': condition,
      'interchangeable': interchangeable,
      'views': views,
      'categories': categories,
      'likes': likes,
      'likedBy': likedBy,
    };
  }

  factory MaterialItem.fromMap(Map<String, dynamic> map) {
    return MaterialItem(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      price: map['price'].toDouble(),
      images: List<String>.from(map['images']),
      owner: map['owner'],
      condition: map['condition'],
      interchangeable: map['interchangeable'],
      views: map['views'],
      categories: List<String>.from(map['categories']),
      likes: map['likes'], 
      likedBy: ['likedBy'],
    );
  }

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      images: List<String>.from(json['images']),
      owner: json['owner'],
      condition: json['condition'],
      interchangeable: json['interchangeable'],
      views: json['views'],
      categories: List<String>.from(json['categories']),
      likes: json['likes'], 
      likedBy: ['likedBy'],
    );
  }

  Future<void> likeItem(bool isLiked, String userId) async {
    try {
      final FirebaseService firebaseService = FirebaseService(); 
      if (isLiked) {
        await firebaseService.likeItem(id, userId);
        likedBy.add(userId);
        likes = likedBy.length;
      } else {
        await firebaseService.unlikeItem(id, userId);
        likedBy.remove(userId);
        likes = likedBy.length;
      }
    } catch (error) {      
      print("Error updating likes: $error");
      rethrow;
    }
  }
}