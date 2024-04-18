import 'package:flutter/material.dart';
import 'package:goatsmart/models/user.dart';
import 'package:goatsmart/pages/allItems.dart';
import 'package:goatsmart/pages/home.dart';
import 'package:goatsmart/pages/addMaterial.dart';
import 'package:goatsmart/pages/userProfile.dart';
import 'package:goatsmart/services/firebase_auth_service.dart';
import 'package:goatsmart/services/firebase_service.dart';

class ItemGallery extends StatefulWidget {
  static const String routeName = 'ItemGallery';
  const ItemGallery({Key? key}) : super(key: key);

  @override
  _ItemGallery createState() => _ItemGallery();
}

class _ItemGallery extends State<ItemGallery> {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _auth = AuthService();
  List<dynamic> itemImages = [];
  String? userImageUrl;
  User? userLoggedIn;
  String? username;

  @override
  void initState() {
    super.initState();
    _fetchLastItemsImages();
    _fetchUserImageUrl();
    _fetchUserLoggedIn();
  }

  Future<void> _fetchLastItemsImages() async {
    var images = await _firebaseService.fetchLastItemsImages();
    print(images);
    if (images.isNotEmpty) {
      setState(() {
        itemImages = images;
      });
    } else {      
      setState(() {
        itemImages = List.generate(4, (index) => 'assets/images/${index + 11}.jpg');
      });
    }
  }

  Future<void> _fetchUserImageUrl() async {
    String? userId = _auth.getCurrentUserId(); 
    User? user = await _firebaseService.getUser(userId); 
    if (user != null) {
      setState(() {
        userImageUrl = user.imageUrl; 
      });
    }
  }

  Future<void> _fetchUserLoggedIn() async {
    String? userId = _auth.getCurrentUserId(); 
    User? user = await _firebaseService.getUser(userId);
    if (user != null) {
      setState(() {
        userLoggedIn = user; 
        username = user.username;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
      toolbarHeight: screenHeight * 0.15,
      leadingWidth: screenWidth * 0.3,
      leading: GestureDetector(
        onTap: () {
          if (userLoggedIn != null && userImageUrl != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfile(user: userLoggedIn!),
              ),
            );
          } else {
            // Handle case when user or userImageUrl is null
          }
        },
        child: userImageUrl != null
            ? CircleAvatar(
                radius: screenWidth * 0.08,
                backgroundImage: NetworkImage(userImageUrl!),
              )
            : const CircleAvatar(
                radius: 30,
                child: Icon(Icons.person),
              ),
      ),

      title: TextField(
        decoration: InputDecoration(
          fillColor: const Color.fromARGB(255, 211, 210, 210),
          filled: true,
          labelText: "Search",
          hintText: "Search",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(screenWidth * 0.04)),
          ),
        ),
      ),        
    ),
      body: FutureBuilder(
        future: _fetchLastItemsImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Text(
                username != null ? 'Hello $username!' : 'Loading...',
                style: userImageUrl != null
                    ? TextStyle(fontSize: screenWidth * 0.08, fontWeight: FontWeight.bold)
                    : TextStyle(fontSize: screenWidth * 0.1, color: const Color.fromARGB(230, 255, 168, 6), fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.02),
                  child: Text(
                    'Just For You',
                    style: TextStyle(fontSize: screenWidth * 0.06),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  child: TextButton(
                    onPressed: () => Navigator.popAndPushNamed(context, HomePage.routeName),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'See All',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: screenWidth * 0.03),
                        ),
                        FloatingActionButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SeeAllItemsView()));
                          },
                          backgroundColor: const Color.fromARGB(230, 255, 168, 6),
                          child: const Icon(Icons.arrow_forward_outlined),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: screenHeight * 0.4,
              child: GridView.count(
                crossAxisCount: screenWidth > 600 ? 4 : 2,
                padding: const EdgeInsets.all(10),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: List.generate(
                  10,
                  (index) => Container(
                    padding: const EdgeInsets.all(8),
                    color: const Color(0xFFE0F7FA),
                    child: Image.asset(
                      'assets/images/${index + 1}.jpg',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Text(
                'New Items',
                style: TextStyle(fontSize: screenWidth * 0.06),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.2,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: itemImages.length,
                itemBuilder: (context, index) {
                  var imageList = itemImages[index];  
                  var imagePath = imageList.isNotEmpty ? imageList[0] : 'assets/images/default.jpg'; 
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      imagePath,
                      errorBuilder: (context, error, stackTrace) {                        
                        return Image.asset('assets/images/default.jpg');
                      },
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMaterialItemView()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
