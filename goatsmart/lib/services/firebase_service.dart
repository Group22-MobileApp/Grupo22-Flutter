import "package:cloud_firestore/cloud_firestore.dart";
import "package:image_picker/image_picker.dart";

FirebaseFirestore db = FirebaseFirestore.instance;

//Guardar los datos del usuario en base de datos
Future <void> addUser(String email, String name, String password, String carrer, String number) async {
  CollectionReference collectionUsers = db.collection("Users");
  await collectionUsers.add({
    'carrer': carrer,
    'email': email,
    'username': name,
    'password': password,
    'id': 5000,
    "number" : 3000000000,
  });
}

// Crear un nuevo post
Future <void> addPost(String category, String description, PickedFile image, String title) async {
  CollectionReference collectionPosts = db.collection("Posts");
  await collectionPosts.add({
    'category': category,
    'description': description,
    'image': image,
    'title': title,
  });
}

//Funcion que lista todos los documentos de la coleccion Posts
Future<List<dynamic>> getPosts() async {
  // ignore: non_constant_identifier_names
  List<dynamic> Posts = [];
  CollectionReference collectionPosts = db.collection("Posts");
  QuerySnapshot querySnapshot = await collectionPosts.get();

  for (var element in querySnapshot.docs) {
    Posts.add(element.data());
  }
  return Posts;
} 


