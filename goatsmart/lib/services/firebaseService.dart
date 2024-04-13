// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goatsmart/models/materialItem.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createMaterialItem(MaterialItem item) async {
    try {
      await _firestore.collection('material_items').doc(item.id).set({
        'title': item.title,
        'description': item.description,
        'price': item.price,
        'images': item.images,
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
}