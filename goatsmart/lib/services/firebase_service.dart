import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goatsmart/models/materialItem.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createMaterialItem(MaterialItem item) async {
    try {
      List<String> imageUrls = [];
      for (var image in item.images) {
        String url = await uploadImage(File(image));
        imageUrls.add(url);
      }

      await _firestore.collection('material_items').doc(item.id).set({
        'title': item.title,
        'description': item.description,
        'price': item.price,
        'images': imageUrls,
        'owner': item.owner,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      rethrow;
    }
  }

  Future<List<MaterialItem>> getMaterialItemsNameDescription() async {
      try {
      QuerySnapshot querySnapshot = await _firestore.collection('material_items').get();
      return querySnapshot.docs.map((doc) {
        final title = doc['title'] ?? '';
        final description = doc['description'] ?? '';
        return MaterialItem(
          id: doc.id,
          title: title,
          description: description,
          price: doc['price'] ?? 0.0,
          images: List<String>.from(doc['images'] ?? []),
          owner: doc['owner'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error getting material items: $e');
      return [];
    }
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      String fileName = 'uploads/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask task = ref.putFile(imageFile);
      TaskSnapshot snapshot = await task;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (error) {
      rethrow;
    }
  }

  Future<List<MaterialItem>> fetchLastItems() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('material_items').orderBy('created_at', descending: true).limit(10).get();
      return querySnapshot.docs.map((doc) {
        final title = doc['title'] ?? '';
        final description = doc['description'] ?? '';
        return MaterialItem(
          id: doc.id,
          title: title,
          description: description,
          price: doc['price'] ?? 0.0,
          images: List<String>.from(doc['images'] ?? []),
          owner: doc['owner'] ?? '',
        );
      }).toList();
    } catch (error) {
      print('Error getting material items: $error');
      return [];
    }
  }

   // Fetch last items images
  Future<List> fetchLastItemsImages() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('material_items').orderBy('created_at', descending: true).limit(10).get();
      return querySnapshot.docs.map((doc) {
        return doc['images'];
      }).toList();
    } catch (e) {
      print('Error getting material items: $e');
      return [];
    }
  }  
  
  Future<List<dynamic>> getPosts() async {
    try {
      List<dynamic> posts = [];
      CollectionReference collectionPosts = _firestore.collection("Posts");
      QuerySnapshot querySnapshot = await collectionPosts.get();
      
      for (var element in querySnapshot.docs) {
        posts.add(element.data());
      }
      return posts;
    } catch (error) {
      print('Error getting posts: $error');
      return [];
    }
  }

  Future<void> addUser(String email, String name, String password, String carrer, String number) async {
    try {
      CollectionReference collectionUsers = _firestore.collection("Users");
      await collectionUsers.add({
        'carrer': carrer,
        'email': email,
        'username': name,
        'password': password,
        'id': 5000,
        "number" : 3000000000,
      });
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addPost(String category, String description, PickedFile image, String title) async {
    try {
      CollectionReference collectionPosts = _firestore.collection("Posts");
      await collectionPosts.add({
        'category': category,
        'description': description,
        'image': image,
        'title': title,
      });
    } catch (error) {
      rethrow;
    }
  }


}
