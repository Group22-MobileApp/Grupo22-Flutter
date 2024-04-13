// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goatsmart/models/materialItem.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<MaterialItem>> getMaterialItems() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('materials').get();
      return querySnapshot.docs.map((doc) => MaterialItem.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting material items: $e');
      return [];
    }
  }

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
}
