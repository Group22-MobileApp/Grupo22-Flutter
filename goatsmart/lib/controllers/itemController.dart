import 'package:get/get.dart';
import 'package:goatsmart/services/firebaseStorageService.dart';
class ItemController extends GetxController{
  final allItemImages =<String>[].obs;

  @override
  void onReady() {
    getAllItems();
    super.onReady();   
  }

  Future<void> getAllItems() async {
    List<String> items = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14'];

    try {
      var fetchImageFutures = items.map((item) => Get.find<FirebaseStorageService>().getImage(item)).toList();
      var imageUrls = await Future.wait(fetchImageFutures);
      for (var imgUrl in imageUrls) {
        if (imgUrl != null) {
          allItemImages.add(imgUrl);
        }
      }
    } catch (e) {
      print('Error fetching all items: $e');
    }
  }
}