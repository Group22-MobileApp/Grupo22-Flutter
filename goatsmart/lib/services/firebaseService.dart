// ignore: file_names
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goatsmart/models/materialItem.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
      });
    } catch (error) {
      throw error;
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
    String fileName = 'uploads/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    Reference ref = FirebaseStorage.instance.ref().child(fileName);
    UploadTask task = ref.putFile(imageFile);
    TaskSnapshot snapshot = await task;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
}

}