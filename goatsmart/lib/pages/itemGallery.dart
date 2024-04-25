import 'package:flutter/material.dart';
import 'package:goatsmart/models/materialItem.dart';
import 'package:goatsmart/models/user.dart';
import 'package:goatsmart/pages/allItems.dart';
// import 'package:goatsmart/pages/home.dart';
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
  List<MaterialItem> lastItems = [];
  List<dynamic> lastItemsImages = [];
  String? userImageUrl;
  User? userLoggedIn;
  String? username;
  List<MaterialItem> itemsForYou = [];
  List<dynamic> itemsForYouImages = [];

  @override
  void initState() {
    super.initState();    
    _fetch_itemsForYou();    
    _fetchLastItems();
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

  Future<void> _fetchLastItems() async {
    List<MaterialItem> items = (await _firebaseService.fetchLastItems()).cast<MaterialItem>();
    if (items.isNotEmpty) {
      setState(() {
        lastItems = items;
        lastItemsImages = items.map((item) => item.images.first).toList();
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
          ? Padding(
              padding: EdgeInsets.all(screenWidth * 0.03), 
              child: CircleAvatar(
                radius: screenWidth * 0.06, 
                backgroundImage: NetworkImage(userImageUrl!),
              ),
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
    body: Column(
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
        ),Row(
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
                  SizedBox(width: screenWidth * 0.02), // Add spacing between text and star
                  Icon(
                    Icons.star,
                    color: const Color.fromARGB(230, 255, 168, 6),
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
                      color: Color.fromARGB(255, 0, 0, 0),
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
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SeeAllItemsView()));
                          },
                          child: SizedBox(
                            width: 46, 
                            height: 46,
                            child: Icon(Icons.arrow_forward_outlined, color: Colors.white),       
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(screenWidth * 0.02),
            children:[
                SizedBox(
                  height: screenHeight * 0.35, // Increase the height of the container to accommodate two rows
                  child: GridView.count(
                    crossAxisCount: screenWidth > 600 ? 4 : 2,
                    padding: const EdgeInsets.all(2),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7, // Adjust the aspect ratio to fit two rows
                    children: List.generate(
                      itemsForYou.length,
                      (index) => GestureDetector(
                        onTap: () => _showItemDialog(context, itemsForYou[index]), 
                        child: Container(
                          height: double.infinity, 
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Color.fromARGB(60, 46, 64, 83), width: 1), 
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, 
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(5), 
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10), 
                                    child: Image.network(
                                      itemsForYouImages[index],
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
                                  style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01), 
                              Padding(                                
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  '\$${_formatPrice(itemsForYou[index].price)}',
                                  style: TextStyle(fontSize: screenWidth * 0.05, color: const Color.fromARGB(255, 138, 136, 136)), 
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02), 
                            ],
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
                      onPressed: () {
                        _fetchLastItems();
                      },
                      icon: Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenHeight * 0.15,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: lastItems.length,
                  itemBuilder: (context, index) {
                    var item = lastItems[index]; 
                    return GestureDetector( 
                      onTap: () => _showItemDialog(context, item), 
                      child: Padding(
                        padding: const EdgeInsets.all(1),
                        child: Image.network(
                          lastItemsImages[index],
                          errorBuilder: (context, error, stackTrace) {                        
                            return Image.asset('assets/images/default.jpg');
                          },
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
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
          content: SingleChildScrollView( 
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