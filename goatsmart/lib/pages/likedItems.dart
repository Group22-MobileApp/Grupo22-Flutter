import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:goatsmart/models/materialItem.dart';
import 'package:goatsmart/models/user.dart';
// import 'package:goatsmart/pages/home.dart';
import 'package:goatsmart/pages/addMaterial.dart';
import 'package:goatsmart/pages/itemGallery.dart';
import 'package:goatsmart/pages/userProfile.dart';
import 'package:goatsmart/services/firebase_auth_service.dart';
import 'package:goatsmart/services/firebase_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';


class LikedItemsGallery extends StatefulWidget {
  static const String routeName = 'LikedItemsGallery';
  const LikedItemsGallery({Key? key}) : super(key: key);

  @override
  _LikedItemsGallery createState() => _LikedItemsGallery();
}

class _LikedItemsGallery extends State<LikedItemsGallery> {
  late SharedPreferences _prefs;
  bool _dataLoaded = false;
  
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _auth = AuthService();    
  User? userLoggedIn;
  String? username;
  List<MaterialItem> itemsForYou = [];
  List<dynamic> itemsForYouImages = [];

  int _selectedIndex = 0;

  List<String> categories = [
    'Textbooks',
    'Notebooks',
    'Stationery',
    'Electronics',
    'Clothing',
    'Accessories',
    'Furniture',
    'Sports Equipment',
    'Musical Instruments',
    'Art Supplies',
    'Kitchenware',
    'Home Appliances',
    'Tools',
    'Beauty & Personal Care',
    'Health & Fitness',
    'Toys & Games',
    'Pet Supplies',
    'Outdoor Gear',
    'Vehicles',
    'Services',
    'Tickets',
    'Events',
    'Miscellaneous',
    'Bottles & Containers',
    'Plants & Gardening',
    'Food & Beverages',
    'Books & Magazines',
    'Movies & Music',
    'Video Games',
    'Board Games',
    'Others'
  ];

  List<String> selectedCategories = [];

  void selectCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category); 
      } else {
        selectedCategories.add(category); 
      }
    });
  }

  void _fetchItemsForCategory(String? category) {
    // Fetch items for the selected category from the server
    // You can implement this based on your Firebase service logic
    // For demonstration purposes, I'll just print the selected category
    print('Fetching items for category: $category');
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const ItemGallery()));
      } else if (index == 1) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LikedItemsGallery()));
      } else if (index == 2) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddMaterialItemView(userLoggedIn: userLoggedIn!)));
      } else if (index == 3) {
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatView()));
      } else if (index == 4) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserProfile(user: userLoggedIn!)));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchItemsForYou();
    _fetchUserLoggedIn();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (!_dataLoaded) {
      _fetchItemsForYou();
      setState(() {
        _dataLoaded = true;
      });
    }
  }

  Future<void> _fetchItemsForYou() async {
    // Check cache first
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Show snackbar with no internet connection
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('No internet connection'),
          duration: Duration(seconds: 30),
        ),
      );
      // No internet connection, fetch from cache
      final cachedData = _prefs.getStringList('itemsForYou');
      if (cachedData != null) {
        setState(() {
          itemsForYou = cachedData.map((jsonString) => MaterialItem.fromJson(jsonDecode(jsonString))).toList();
          itemsForYouImages = itemsForYou.map((item) => item.images.first).toList();
        });
      }
      return;
    }
    // Fetch from server

    String career = userLoggedIn!.carrer;
    List<MaterialItem> items =
        (await _firebaseService.fetchItemsByUserCareer(career))
            .cast<MaterialItem>();
    if (items.isNotEmpty) {
      setState(() {
        itemsForYou = items;
        itemsForYouImages = items.map((item) => item.images.first).toList();
      });
      // Save to cache
      final jsonList = items.map((item) => jsonEncode(item.toMap())).toList();
      await _prefs.setStringList('itemsForYou', jsonList);
    } else {
      // Show white with red font dialog with no items found
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              'No items found',
              style: TextStyle(color: Colors.red),
            ),
            content: Text('No items found for your career: $career'),
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

  Future<void> _fetchUserLoggedIn() async {
    String? userId = _auth.getCurrentUserId();
    User? user = await _firebaseService.getUser(userId);
    if (user != null) {
      setState(() {
        userLoggedIn = user;
        username = user.username;
      });
      _fetchItemsForYou();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(screenWidth, context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text "Select one or more categories you like"
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Text(
              'Select one or more categories you like',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E4053),
              ),
            ),
          ),        
          _selectCategoriesContainer(),          
          _refreshButton(),         
          //      
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(screenWidth * 0.02),
              children: [
                _justForYouContainer(screenHeight, screenWidth, context),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomNavBar(),
    );
  }

  Container _selectCategoriesContainer() {
    return Container(
          height: 240,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 2,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategories.contains(category);
              return InkWell(
                onTap: () => selectCategory(category),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                    color: isSelected ? const Color(0xFF2E4053) : Colors.white,
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
  }

  Padding _refreshButton() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),                                        
            color: const Color(0xFFF7DC6F),
          ),
          child: ElevatedButton(
            onPressed: () => _fetchItemsForCategory(selectedCategories.first),
            style: ElevatedButton.styleFrom(                      
              backgroundColor: const Color(0xFFF7DC6F),
              padding: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Refresh'
            , style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
              color: Color(0xFF2E4053),
            ),),
          ),
        ),
      );
  }


  AppBar _appBar(double screenWidth, BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        'Liked Items',
        style: TextStyle(
          color: Colors.black,
          fontSize: screenWidth * 0.06,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: IconButton(
            onPressed: () {
              _auth.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            icon: Icon(Icons.logout),
          ),
        ),
      ],
    );
  }
  
  BottomNavigationBar _bottomNavBar() {
    return BottomNavigationBar(        
      backgroundColor: Colors.white,
      selectedItemColor: const Color.fromARGB(255, 0, 0, 0),
      unselectedItemColor: const Color.fromARGB(255, 138, 136, 136),

      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Liked Items',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Add',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  SizedBox _justForYouContainer(double screenHeight, double screenWidth, BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.35,
      child: GridView.count(
        crossAxisCount: screenWidth > 600 ? 4 : 3,
        padding: const EdgeInsets.all(2),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.45,
        children: List.generate(
          itemsForYou.length,
          (index) => GestureDetector(
            onTap: () => _showItemDialog(context, itemsForYou[index]),
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color.fromARGB(60, 46, 64, 83),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: (itemsForYouImages[index] as String).startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: itemsForYouImages[index] as String,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                memCacheHeight: 300,
                                memCacheWidth: 220,
                              )
                            : Image.asset(
                                itemsForYouImages[index] as String,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.0001),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      itemsForYou[index].title,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      '\$${_formatPrice(itemsForYou[index].price)}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: const Color.fromARGB(255, 138, 136, 136),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),                  
                  HeartIconButton(
                    isLiked: itemsForYou[index].likes > 0,
                    onTap: (bool isLiked) async {
                      try {
                        await itemsForYou[index].increaseLikes(isLiked);
                        setState(() {
                          if (isLiked) {
                            itemsForYou[index].likes++;
                          } else {
                            itemsForYou[index].likes--;
                          }
                        });
                      } catch (error) {
                        // Handle error
                        print('Error updating item likes: $error');
                      }
                      try {    
                        if (isLiked) {
                          await userLoggedIn!.likeItem(itemsForYou[index].id);
                        } else {
                          await userLoggedIn!.unlikeItem(itemsForYou[index].id);
                        }
                      } catch (error) {
                        // Handle error updating user liked items
                        print('Error updating user liked items: $error');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    String formattedPrice = price.toStringAsFixed(2);
    return NumberFormat.currency(locale: 'en_US', symbol: '')
        .format(double.parse(formattedPrice));
  }

  Future<void> _showItemDialog(BuildContext context, MaterialItem item) async {
    User? user = await _firebaseService.getUser(item.owner);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(item.title),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.images.isNotEmpty && item.images.first.startsWith('http'))
                  CachedNetworkImage(
                    imageUrl: item.images.first,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    memCacheHeight: 800,
                    memCacheWidth: 600,
                  )
                  else
                  Image.asset(
                    item.images.first,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 8.0),
                  Text('Description: ${item.description}'),
                  const SizedBox(height: 8.0),
                  Text('Price: \$${_formatPrice(item.price)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (user != null) ...[
                    const SizedBox(height: 8.0),
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
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}


class HeartIconButton extends StatelessWidget {
  final bool isLiked;
  final Function(bool) onTap;

  HeartIconButton({
    required this.isLiked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        onTap(!isLiked);
      },
      icon: Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        color: isLiked ? Colors.red : Colors.grey,
      ),
    );
  }
}