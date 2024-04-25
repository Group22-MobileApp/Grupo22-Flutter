import 'package:flutter/material.dart';
import 'package:goatsmart/models/materialItem.dart';
import 'package:goatsmart/models/user.dart';
import 'package:goatsmart/pages/allItems.dart';
import 'package:goatsmart/pages/home.dart';
import 'package:goatsmart/pages/addMaterial.dart';
import 'package:goatsmart/pages/userProfile.dart';
import 'package:goatsmart/services/firebase_auth_service.dart';
import 'package:goatsmart/services/firebase_service.dart';
import 'package:intl/intl.dart'; 

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
  List<MaterialItem> itemsForYou = [];
  List<dynamic> itemsForYouImages = [];

  @override
  void initState() {
    super.initState();    
    _fetch_itemsForYou();
    _fetchLastItemsImages();
    _fetchUserImageUrl();
    _fetchUserLoggedIn();
  }

  Future<void> _fetch_itemsForYou() async {
    String career = userLoggedIn!.carrer;
    print("Career: $career");
    List<MaterialItem> items = (await _firebaseService.fetchItemsByUserCareer(career)).cast<MaterialItem>();
    print("Items: $items");
    if (items.isNotEmpty) {
      setState(() {
        itemsForYou = items;
        itemsForYouImages = items.map((item) => item.images.first).toList();
      });
    } else {      
      itemsForYou = List.generate(10, (index) => MaterialItem(
        id: index.toString(),
        title: 'Example Item $index',
        description: 'Example Description $index',
        price: 0.0,
        images: ['assets/images/${index + 1}.jpg'],
        owner: 'Example Owner $index',
      ));
      itemsForYouImages = List.generate(10, (index) => 'assets/images/${index + 1}.jpg');
    }
  }

  Future<void> _fetchLastItemsImages() async {
    var images = await _firebaseService.fetchLastItemsImages();    
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
      _fetch_itemsForYou();
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
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Error'),
                    content: const Text('User not found. Please try again later.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );                            
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Text(
                // 'Hello, Adriana!',
                // userImageUrl ?? _auth.getCurrentUserId(),
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
              height: screenHeight * 0.35,
              child: GridView.count(
                crossAxisCount: screenWidth > 600 ? 4 : 2,
                padding: const EdgeInsets.all(10),
                crossAxisSpacing: 2,
                mainAxisSpacing: 1,
                children: List.generate(
                  itemsForYou.length,
                  (index) => GestureDetector(
                    onTap: () => _showItemDialog(context, itemsForYou[index]), // Add onTap functionality
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      color:const Color(0xFFF7DC6F),
                      child: Image.network(
                        itemsForYouImages[index],
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Row(
                children: [
                  Text(
                    'New Items',
                    style: TextStyle(fontSize: screenWidth * 0.06),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: _fetchLastItemsImages,
                    icon: Icon(Icons.refresh),
                  ),
                ],
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMaterialItemView()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  
    String _formatPrice(double price) {
      String formattedPrice = price.toStringAsFixed(2);
      return NumberFormat.currency(locale: 'en_US', symbol: '').format(double.parse(formattedPrice));
    }

  Future<void> _showItemDialog(BuildContext context, MaterialItem item) async {
    User? user = await _firebaseService.getUser(item.owner);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(item.title),
          content: SingleChildScrollView( // Wrap content with SingleChildScrollView
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.images.isNotEmpty)
                    Image.network(
                      item.images.first,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  SizedBox(height: 8.0),
                  Text('Description: ${item.description}'),
                  SizedBox(height: 8.0),
                  Text('Price: \$${_formatPrice(item.price)}', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (user != null) ...[
                    SizedBox(height: 8.0),                  
                    Text('Owner username: ${user.username}'),
                    Text('Owner name: ${user.name}'),
                    Text('Email: ${user.email}'),                  
                    Text('Career: ${user.carrer}'),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}