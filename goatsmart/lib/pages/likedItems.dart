import 'dart:convert';
import 'dart:math';
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
  List<MaterialItem> likedItemsForYou = [];
  List<dynamic> likedItemsForYouImages = [];

  int _selectedIndex = 0;

  int rand = Random().nextInt(14) + 1;

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
  List<String> likedCategories = [];

  void selectCategory(String category) {    
    setState(() {
      //Check if category is already selected and or liked
      if (likedCategories.contains(category)) {        
        likedCategories.remove(category);
        print("Liked category removed: $category");
        print("Liked categories: $likedCategories");
        return;
      }
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }     
    });
    print("Selected categories: $selectedCategories");    
  }

  void _addCategoriesToUser() async {
    try {      
      selectedCategories.addAll(likedCategories);
      await userLoggedIn!.addLikedCategories(selectedCategories);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Categories updated successfully'),
          duration: Duration(seconds: 5),
        ),
      );
      // Refresh page      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LikedItemsGallery(),
        ),
      );
      _fetchUserLoggedIn();
    } catch (error) {
      // Handle error
      print('Error adding categories to user: $error');
    }
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
    _fetchLikedItemsForYou();
    _fetchUserLoggedIn();
    _fetchLikedCategories();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (!_dataLoaded) {
      _fetchLikedItemsForYou();      
      setState(() {
        _dataLoaded = true;
      });
    }
  }

  Future<void> _fetchLikedItemsForYou() async {
    // Check cache first
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Show snackbar with no internet connection
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('No internet connection'),
          duration: Duration(seconds: 3),
        ),
      );
      // No internet connection, fetch from cache
      final cachedData = _prefs.getStringList('likedItemsForYou');
      if (cachedData != null) {
        setState(() {
          likedItemsForYou = cachedData.map((jsonString) => MaterialItem.fromJson(jsonDecode(jsonString))).toList();
          likedItemsForYouImages = likedItemsForYou.map((item) => item.images.first).toList();
        });
      }
      return;
    }
    // Fetch from server

      List<MaterialItem> items =
          (await _firebaseService.fetchItemsByLikedCategories(likedCategories))
              .cast<MaterialItem>();
      if (items.isNotEmpty) {
        setState(() {
          likedItemsForYou = items;
          likedItemsForYouImages = items.map((item) => item.images.first).toList();
        });
        // Save to cache
        final jsonList = items.map((item) => jsonEncode(item.toMap())).toList();
        await _prefs.setStringList('likedItemsForYou', jsonList);
      } else {        
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('No items found for your liked categories: $likedCategories'),
          duration: const Duration(seconds: 2),
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
        likedCategories = user.likedCategories;
        print("Liked categories: $likedCategories");
      });
      _fetchLikedItemsForYou();
    }
  }

  Future<void> _fetchLikedCategories() async {
    String? userId = _auth.getCurrentUserId();
    User? user = await _firebaseService.getUser(userId);
    if (user != null) {
      setState(() {
        likedCategories = _firebaseService.getLikedCategories(user.id) as List<String>;
        print("Liked categories: $likedCategories");
      });
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
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 2,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategories.contains(category);
          final isLikedCategory = likedCategories.contains(category);

          return InkWell(
            onTap: () => selectCategory(category),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
                // color: isSelected ? const Color(0xFF2E4053) : (isLikedCategory ? Colors.green : Colors.white),                
                // Is selected or liked category, green color, else white
                color: isSelected || isLikedCategory ? Colors.green : Colors.white,
              ),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  category,
                  style: TextStyle(
                    // color: isSelected ? Colors.white : (isLikedCategory ? Colors.white : Colors.black),                    
                    // Is selected or liked category, white color, else red
                    color: isSelected || isLikedCategory ? Colors.white : Colors.black,
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
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),                                        
            color: const Color(0xFFF7DC6F),
          ),
          child: ElevatedButton(
            onPressed: () => _addCategoriesToUser(),
            style: ElevatedButton.styleFrom(                      
              backgroundColor: const Color(0xFFF7DC6F),
              padding: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Refresh categories'
            , style: TextStyle(
              fontSize: 15,
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
            icon: const Icon(Icons.logout),
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
          likedItemsForYou.length,
          (index) => GestureDetector(
            onTap: () => _showItemDialog(context, likedItemsForYou[index]),
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
                        child: (likedItemsForYouImages[index] as String).startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: likedItemsForYouImages[index] as String,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                memCacheHeight: 300,
                                memCacheWidth: 220,
                                errorWidget: (context, error, stackTrace) {
                                  return Image.asset('assets/images/$rand.jpg');
                                },
                              )
                            : Image.asset(
                                likedItemsForYouImages[index] as String,
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
                      likedItemsForYou[index].title,
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
                      '\$${_formatPrice(likedItemsForYou[index].price)}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: const Color.fromARGB(255, 138, 136, 136),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),                  
                  HeartIconButton(
                    isLiked: likedItemsForYou[index].likes > 0,
                    onTap: (bool isLiked) async {
                      try {
                        await likedItemsForYou[index].increaseLikes(isLiked);
                        setState(() {
                          if (isLiked) {
                            likedItemsForYou[index].likes++;
                          } else {
                            likedItemsForYou[index].likes--;
                          }
                        });
                      } catch (error) {
                        // Handle error
                        print('Error updating item likes: $error');
                      }
                      try {    
                        if (isLiked) {
                          await userLoggedIn!.likeItem(likedItemsForYou[index].id);
                        } else {
                          await userLoggedIn!.unlikeItem(likedItemsForYou[index].id);
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
                    errorWidget: (context, error, stackTrace) {
                      return Image.asset('assets/images/$rand.jpg');
                    },
                  )
                  else
                  Image.asset(
                    item.images.first,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 8.0),
                  const SizedBox(height: 8.0),
                  Text('Description: ${item.description}'),
                  Text('Categories: ${item.categories.join(', ')}'),                
                  Text('Condition: ${item.condition}'),
                  Text('Interchangeable: ${item.interchangeable}'),
                  Text('Views: ${item.views}'),
                  Text('Likes: ${item.likes}'),                  
                  Text('Price: \$${_formatPrice(item.price)}', style: const TextStyle(fontWeight: FontWeight.bold)),
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

  const HeartIconButton({Key? key, 
    required this.isLiked,
    required this.onTap,
  }) : super(key: key);

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