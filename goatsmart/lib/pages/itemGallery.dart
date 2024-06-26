import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:goatsmart/models/materialItem.dart';
import 'package:goatsmart/models/user.dart';
import 'package:goatsmart/pages/allItems.dart';
import 'package:goatsmart/pages/addMaterial.dart';
import 'package:goatsmart/pages/likedItems.dart';
import 'package:goatsmart/pages/searchPage.dart';
import 'package:goatsmart/pages/userProfile.dart';
import 'package:goatsmart/services/dialogService.dart';
import 'package:goatsmart/services/firebase_auth_service.dart';
import 'package:goatsmart/services/firebase_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:goatsmart/pages/homeChat.dart';
import 'package:goatsmart/services/control_features.dart';

class ItemGallery extends StatefulWidget {
  static const String routeName = 'ItemGallery';
  const ItemGallery({Key? key}) : super(key: key);

  @override
  _ItemGallery createState() => _ItemGallery();
}

class _ItemGallery extends State<ItemGallery> {
  late SharedPreferences _prefs;
  bool _dataLoaded = false;  
  final FirebaseService _firebaseService = FirebaseService();
  final _controlFeatures = ConnectionManager();
  final AuthService _auth = AuthService();
  final _dialogService = DialogService();
  List<MaterialItem> lastItems = [];
  List<dynamic> lastItemsImages = [];
  String? userImageUrl;
  User? userLoggedIn;
  String? username;
  List<MaterialItem> itemsForYou = [];
  List<dynamic> itemsForYouImages = [];  

  int _selectedIndex = 0;
  int rand = Random().nextInt(14) + 1;
  bool using_random_items_just_for_you = false;
  bool using_random_items_new_items = false;

  void _onItemTapped(int index) async {
    bool isConnected = await _controlFeatures.checkInternetConnection();
    if (!isConnected && index == 3) {
      print("Internet is not connected");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              'No Internet Connection',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            content: const Text('Please check your internet connection and try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
    
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ItemGallery()));
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LikedItemsGallery()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AddMaterialItemView(userLoggedIn: userLoggedIn!)));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeChat()));
    } else if (index == 4) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfile(user: userLoggedIn!)));
    }
  }


  @override
  void initState() {
  super.initState();
  _fetchUserImageUrl();
  _fetchUserLoggedIn().then((_) {
    _fetchItemsForYou();    
    _fetchLastItems();
  });
  _initPrefs();
}

  Future<void> _welcomeMessage() async {
    int cont = await _auth.getNumberOfUsersLoggedInLast30Days();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Bienvenido! '),
              backgroundColor: Colors.white,
              content: Text('Estamos felices de tenerte en nuestra plataforma! Ya somos $cont usuarios activos!'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();    
    if (!_dataLoaded) {
      _fetchItemsForYou();
      _fetchLastItems();      
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
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('No internet connection'),
          duration: Duration(seconds: 3),
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
    
    List<MaterialItem> items =
        (await _firebaseService.fetchLikedItems(userLoggedIn!.id)).cast<MaterialItem>();            
    if (items.isNotEmpty) {
      setState(() {
        using_random_items_just_for_you = false;
        itemsForYou = items;
        itemsForYouImages = items.map((item) => item.images.first).toList();
      });
      // Save to cache
      final jsonList = items.map((item) => jsonEncode(item.toMap())).toList();
      await _prefs.setStringList('itemsForYou', jsonList);
    } else {
      _fetchLastItems();
      setState(() {        
        using_random_items_just_for_you = true;
        itemsForYouImages =
            List.generate(10, (index) => 'assets/images/${index + 1}.jpg');
        itemsForYou = List.generate(
            10,
            (index) => MaterialItem(
                  id: index.toString(),
                  title: 'Example Item $index',
                  description:
                      'No items found for your career ${userLoggedIn?.carrer} to recommend. However, this is an example of how the items would look like.',
                  price: Random().nextDouble() * 100000,
                  images: [itemsForYouImages[index]],
                  owner: 'Example Owner $index',
                  condition: 'New',
                  interchangeable: 'No',
                  views: Random().nextInt(1000),
                  categories: ['Example Category $index'],
                  likes: Random().nextInt(100),
                  likedBy: [userLoggedIn!.id],
                ));
      });
    }
  }

  Future<void> _fetchLastItems() async {
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
      final cachedData = _prefs.getStringList('lastItems');
      if (cachedData != null) {
        setState(() {
          lastItems = cachedData.map((jsonString) => MaterialItem.fromJson(jsonDecode(jsonString))).toList();
          lastItemsImages = lastItems.map((item) => item.images.first).toList();
        });
      }
      return;
    }

    // Fetch from server
    List<MaterialItem> items =
        (await _firebaseService.fetchLastItems()).cast<MaterialItem>();
    if (items.isNotEmpty) {
      setState(() {
        using_random_items_new_items = false;
        lastItems = items;
        lastItemsImages = items.map((item) => item.images.first).toList();
      });
      // Save to cache
      final jsonList = items.map((item) => jsonEncode(item.toMap())).toList();
      await _prefs.setStringList('lastItems', jsonList);
    } else {
      setState(() {      
        using_random_items_new_items = true;
        lastItemsImages =
            List.generate(10, (index) => 'assets/images/${index + 1}.jpg');
        lastItems = List.generate(
            10,
            (index) => MaterialItem(
                  id: index.toString(),
                  title: 'Example Item $index',
                  description:
                      'No items found for your career ${userLoggedIn?.carrer} to recommend. However, this is an example of how the items would look like.',
                  price: Random().nextDouble() * 100000,
                  images: [lastItemsImages[index]],
                  owner: 'Example Owner $index',
                  condition: 'New',
                  interchangeable: 'No',
                  views: Random().nextInt(1000),
                  categories: ['Example Category $index'],
                  likes: Random().nextInt(100),
                  likedBy: [userLoggedIn!.id],
                ));
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
      _fetchItemsForYou();
      _fetchLastItems();     
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(screenHeight, screenWidth, context),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _welcome(screenWidth),
          _topNavBar(screenWidth, context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(screenWidth * 0.02),
              children: [
                _justForYouContainer(screenHeight, screenWidth, context),
                _newItemsTitleAndRefresh(screenWidth),
                _newItemsContainer(screenHeight),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _addMaterialButton(context),
      bottomNavigationBar: _bottomNavBar(),
    );
  }

  Padding _newItemsTitleAndRefresh(double screenWidth) {
    return Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Row(
                  children: [
                    Text(
                      'New Items',
                      style: TextStyle(fontSize: screenWidth * 0.06),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        _fetchLastItems();
                        _fetchItemsForYou();                                 
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              );
  }

  FloatingActionButton _addMaterialButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddMaterialItemView(userLoggedIn: userLoggedIn!)));    
      },
      child: const Icon(Icons.add),
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

  SizedBox _newItemsContainer(double screenHeight) {
    return SizedBox(
                height: screenHeight * 0.15,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: lastItems.length,
                  itemBuilder: (context, index) {
                    var item = lastItems[index];
                    // If using random items don't allow to tap on them
                    if (using_random_items_new_items) {
                      return Padding(
                        padding: const EdgeInsets.all(1),
                        child: CachedNetworkImage(
                          imageUrl: lastItemsImages[index],
                          errorWidget: (context, error, stackTrace) {   
                            using_random_items_new_items = true;                                                     
                            return Image.asset('assets/images/$rand.jpg');
                          },
                          fit: BoxFit.cover,
                          memCacheHeight: 300,
                          memCacheWidth: 220,
                        ),
                      );                      
                    }
                    return GestureDetector(
                      onTap: () => _dialogService.showItemDialog(context, item, rand, userLoggedIn!),
                      child: Padding(
                        padding: const EdgeInsets.all(1),
                        child: CachedNetworkImage(
                          imageUrl: lastItemsImages[index],
                          errorWidget: (context, error, stackTrace) {         
                            using_random_items_new_items = true;                                               
                            return Image.asset('assets/images/$rand.jpg');
                          },
                          fit: BoxFit.cover,
                          memCacheHeight: 300,
                          memCacheWidth: 220,
                        ),
                      ),
                    );
                  },
                ),
              );
  }

  SizedBox _justForYouContainer(double screenHeight, double screenWidth, BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.35,
      child: GridView.count(
        crossAxisCount: screenWidth > 600 ? 4 : 2,
        padding: const EdgeInsets.all(2),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.65,
        children: List.generate(
          itemsForYou.length,
          (index) => _justForYouGesture(context, index, screenHeight, screenWidth),
        ),
      ),
    );
  }

  GestureDetector _justForYouGesture(BuildContext context, int index, double screenHeight, double screenWidth) {
    if (using_random_items_just_for_you) {
          return GestureDetector(
            onTap: () {
              // Do nothing
            },
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
                        child: Image.asset('assets/images/${index + 1}.jpg'),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.0001),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Example Item $index',
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
                      '\$${_formatPrice(Random().nextDouble() * 100000)}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        color: const Color.fromARGB(255, 138, 136, 136),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  HeartIconButton(
                    isLiked: false,
                    onTap: (bool isLiked) {
                      // Do nothing
                    },
                  ),
                ],
              ),
            ),
          );
        }        
  return GestureDetector(            
      onTap: () => _dialogService.showItemDialog(context, itemsForYou[index], rand, userLoggedIn!),
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
                          errorWidget: (context, error, stackTrace) {
                            using_random_items_just_for_you = true;
                            return Image.asset('assets/images/$rand.jpg');
                          },
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
                  fontSize: screenWidth * 0.05,
                  color: const Color.fromARGB(255, 138, 136, 136),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),                  
            HeartIconButton(
              isLiked: itemsForYou[index].likedBy.contains(userLoggedIn!.id),
              onTap: (bool isLiked) async {
                try {
                  await itemsForYou[index].likeItem(isLiked, userLoggedIn!.id);
                  setState(() {
                    if (isLiked) {                            
                      itemsForYou[index].likedBy.add(userLoggedIn!.id);
                    } else {                            
                      itemsForYou[index].likedBy.removeWhere((id) => id == userLoggedIn!.id);
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
    );
  }

  Row _topNavBar(double screenWidth, BuildContext context) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.02),
              child: Row(
                children: [
                  Text(
                    'Just For You',
                    style: TextStyle(fontSize: screenWidth * 0.06),
                  ),
                  SizedBox(
                      width: screenWidth *
                          0.02), // Add spacing between text and star
                  const Icon(
                    Icons.star,
                    color: Color.fromARGB(230, 255, 168, 6),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'See All',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ClipOval(
                      child: Material(
                        color: const Color.fromARGB(230, 255, 168, 6),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SeeAllItemsView(userLoggedIn: userLoggedIn!)));
                          },
                          child: const SizedBox(
                            width: 46,
                            height: 46,
                            child: Icon(Icons.arrow_forward_outlined,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
  }

  Padding _welcome(double screenWidth) {
    return Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Text(
            username != null ? 'Hello $username!' : 'Loading...',
            style: userImageUrl != null
                ? TextStyle(
                    fontSize: screenWidth * 0.08, fontWeight: FontWeight.bold)
                : TextStyle(
                    fontSize: screenWidth * 0.1,
                    color: const Color.fromARGB(230, 255, 168, 6),
                    fontWeight: FontWeight.bold),
          ),
        );
  }

  AppBar _appBar(double screenHeight, double screenWidth, BuildContext context) {
    return AppBar(
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
                    content:
                        const Text('User not found. Please try again later.'),
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
          ? Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: CircleAvatar(
                radius: screenWidth * 0.06,
                backgroundImage: CachedNetworkImageProvider(userImageUrl!),                  
              ),
            )
          : const CircleAvatar(
              radius: 30,
              child: Icon(Icons.person),
            ),
        ),
        title: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage()));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 211, 210, 210),
                      filled: true,
                      labelText: "Search",
                      hintText: "Search",
                      prefixIcon: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage()));
                        },
                        child: const Icon(Icons.search),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(screenWidth * 0.04)),
                      ),                       
                    ),
                    onChanged: (value) {
                      // Handle text change                        
                    },
                    onSubmitted: (value) {
                      // Handle submission
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage()));
                    },
                  ),
                ),                  
              ],
            ),
          ),
        ));
  }
  String _formatPrice(double price) {
    String formattedPrice = price.toStringAsFixed(2);
    return NumberFormat.currency(locale: 'en_US', symbol: '')
        .format(double.parse(formattedPrice));
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