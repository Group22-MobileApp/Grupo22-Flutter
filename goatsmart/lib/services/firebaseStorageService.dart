import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

Reference get firebaseStorageRef => FirebaseStorage.instance.ref(); 

class FirebaseStorageService extends GetxService {
  Future<String?> getImage(String? imgName) async {
    if (imgName == null) {
      print("No image name provided");
      return null;
    }

    try {
      var urlRef = firebaseStorageRef
          .child('gs://goatmart-95c34.appspot.com/items')
          .child('${imgName.toLowerCase()}.jpg');
      var imgUrl = await urlRef.getDownloadURL();
      print("Fetched image URL: $imgUrl");
      return imgUrl;
    } catch (e) {
      print('Error fetching image URL for $imgName: $e');
      return null;
    }
  }
}