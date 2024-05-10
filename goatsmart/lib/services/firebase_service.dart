import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:goatsmart/models/user.dart';
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
        'condition': item.condition,
        'interchangeable': item.interchangeable,
        'views': item.views,
        'categories': item.categories,
        'likes': item.likes,
      });
    } catch (error) {
      rethrow;
    }
  }

  Future<List<MaterialItem>> getMaterialItems() async {
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
          condition: doc['condition'] ?? 'New',
          interchangeable: doc['interchangeable'] ?? 'No',
          views: doc['views'] ?? 0,
          categories: List<String>.from(doc['categories'] ?? []),
          likes: doc['likes'] ?? 0,
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
          condition: doc['condition'] ?? 'New',
          interchangeable: doc['interchangeable'] ?? 'No',
          views: doc['views'] ?? 0,
          categories: List<String>.from(doc['categories'] ?? []),
          likes: doc['likes'] ?? 0,
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

    Future<List> fetchLastItemsTittle() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('material_items').orderBy('created_at', descending: true).limit(5).get();
      return querySnapshot.docs.map((doc) {
        return doc['title'];
      }).toList();
    } catch (e) {
      print('Error getting material items: $e');
      return [];
    }
  }  
  
  Future<List<dynamic>> getPosts() async {
    try {
      List<dynamic> posts = [];
      CollectionReference collectionPosts = _firestore.collection("material_items");
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

  Future<List> fetchItemsByUserCareer(String career) async {
    try {      
      List usersId = await fetchUsersIdCareer(career);      
      QuerySnapshot querySnapshot = await _firestore.collection('material_items').where('owner', whereIn: usersId).get();
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
          condition: doc['condition'] ?? 'New',
          interchangeable: doc['interchangeable'] ?? 'No',
          views: doc['views'] ?? 0,
          categories: List<String>.from(doc['categories'] ?? []),
          likes: doc['likes'] ?? 0,
        );
      }).toList();
    } catch (error) {
      print('Error getting material items: $error');
      return [];
    }
  }

  // Method to increment or descrease attribute likes from itemMaterial
  Future<void> increaseLikes(String id, bool increment) async {
    try {
      DocumentReference itemRef = _firestore.collection('material_items').doc(id);
      DocumentSnapshot itemSnapshot = await itemRef.get();
      int likes = itemSnapshot['likes'] ?? 0;
      if (increment) {
        likes++;
      } else {
        likes--;
      }
      await itemRef.update({'likes': likes});
    } catch (error) {
      rethrow;
    }
  }


  Future<void> addUser(User user) async {
    try {
      CollectionReference collectionUsers = _firestore.collection("Users");
      await collectionUsers.add({
        'carrer': user.carrer,
        'email': user.email,
        'username': user.username,
        'password': user.password,
        'id': user.id,
        'number': user.number,
        'imageUrl': user.imageUrl,
        'name': user.name,
        'likedCategories': user.likedCategories,
      });
    } catch (error) {
      rethrow;
    }
  }


  Future<void> editUser(User user) async {
  try {
    // Primero, obtén la referencia del documento del usuario que quieres editar
    DocumentReference userRef = _firestore.collection('Users').doc(user.id);

    // Luego, actualiza los campos necesarios del documento con los nuevos valores
    await userRef.update({
      'carrer': user.carrer,
      'email': user.email,
      'username': user.username,
      'password': user.password,
      'number': user.number,
      'imageUrl': user.imageUrl,
      'name': user.name,
      'likedCategories': user.likedCategories,  
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

  Future<User?> getUser(String userId) async {
    try {
      // Look for 'id' parameter in the Users collection. Not id of firestore document
      QuerySnapshot querySnapshot = await _firestore.collection('Users').where('id', isEqualTo: userId).get();
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        List<String>? likedCategories;
        if (data != null && (data as Map).containsKey('likedCategories')) {
          likedCategories = List<String>.from(data['likedCategories'] as List<dynamic>);
        }
        return User(
          carrer: doc['carrer'],
          email: doc['email'],
          username: doc['username'],
          password: doc['password'],
          id: doc['id'],
          number: doc['number'],
          imageUrl: doc['imageUrl'],
          name: doc['name'],
          likedCategories: likedCategories ?? [],
        );
      }
      return null;
    } catch (error) {
      print('Error getting user: $error');
      return null;
    }
  }

  Future<List> fetchUsersIdCareer(String career) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('Users').where('carrer', isEqualTo: career).get();
      return querySnapshot.docs.map((doc) {
        return doc['id'];
      }).toList();
    } catch (error) {
      print('Error getting users: $error');
      return [];
    }
  }    
  //Metod to get the user by the email
  Future<User?> getUserByEmail(String email) async {
    try {
      // Look for 'email' parameter in the Users collection. Not id of firestore document
      QuerySnapshot querySnapshot = await _firestore.collection('Users').where('email', isEqualTo: email).get();
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        List<String>? likedCategories;
        if (data != null && (data as Map).containsKey('likedCategories')) {
          likedCategories = List<String>.from(data['likedCategories'] as List<dynamic>);
        }
        return User(
          carrer: doc['carrer'],
          email: doc['email'],
          username: doc['username'],
          password: doc['password'],
          id: doc['id'],
          number: doc['number'],
          imageUrl: doc['imageUrl'],
          name: doc['name'],
          likedCategories: likedCategories ?? [],
        );
      }
      return null;
    } catch (error) {
      print('Error getting user: $error');
      return null;
    }
  }

  // method to get the most popular carrer of the users profile
  Future<String> getMostPopularCarrer() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('Users').get();
      Map<String, int> carrers = {};
      for (var doc in querySnapshot.docs) {
        String carrer = doc['carrer'];
        if (carrers.containsKey(carrer)) {
          carrers[carrer] = carrers[carrer]! + 1;
        } else {
          carrers[carrer] = 1;
        }
      }
      String mostPopularCarrer = '';
      int max = 0;
      carrers.forEach((key, value) {
        if (value > max) {
          max = value;
          mostPopularCarrer = key;
        }
      });
      return mostPopularCarrer;
    } catch (error) {
      print('Error getting most popular carrer: $error');
      return '';
    }
  }

  //method to get the posts with the same title
  Future<List> getPostByTitle(String title) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('material_items').where('title', isEqualTo: title).get();
      return querySnapshot.docs.map((doc) {
        return doc.data();
      }).toList();
    } catch (error) {
      print('Error getting post by title: $error');
      return [];
    }
  }

  void addView(String title) {
    _firestore.collection('material_items').where('title', isEqualTo: title).get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        int views = doc['views'] ?? 0;
        _firestore.collection('material_items').doc(doc.id).update({'views': views + 1});
      });
    });
  }

  
}
