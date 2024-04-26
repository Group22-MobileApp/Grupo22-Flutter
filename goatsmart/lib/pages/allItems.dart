import 'package:flutter/material.dart';
import 'package:goatsmart/models/materialItem.dart';
import 'package:goatsmart/models/user.dart';
import 'package:goatsmart/pages/addMaterial.dart';
import 'package:goatsmart/pages/itemGallery.dart';
import 'package:goatsmart/pages/userProfile.dart';
import 'package:goatsmart/services/firebase_service.dart';
import 'package:intl/intl.dart'; 

class SeeAllItemsView extends StatefulWidget {  
  final User userLoggedIn;
  const SeeAllItemsView({Key? key, required this.userLoggedIn}) : super(key: key);
  @override
  _SeeAllItemsViewState createState() => _SeeAllItemsViewState(userLoggedIn);
}

class _SeeAllItemsViewState extends State<SeeAllItemsView> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<MaterialItem>> _materialItemsFuture;  

  int _selectedIndex = 0;
  
  User userLoggedIn;
  
  _SeeAllItemsViewState(this.userLoggedIn);

  @override
  void initState() {
    super.initState();
    _materialItemsFuture = _firebaseService.getMaterialItems();   
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const ItemGallery()));
      } else if (index == 1) {
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const LikeItemsView()));
      } else if (index == 2) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddMaterialItemView(userLoggedIn: userLoggedIn)));
      } else if (index == 3) {
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatView()));
      } else if (index == 4) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserProfile(user : userLoggedIn)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      backgroundColor: const Color.fromARGB(255, 246, 246, 246),
      appBar: AppBar(
        title: const Text('All Items'),
      ),
      body: FutureBuilder<List<MaterialItem>>(
        future: _materialItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<MaterialItem> materialItems = snapshot.data!;
            return SizedBox(
              height: MediaQuery.of(context).size.height ,
              child: GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 1,
                padding: const EdgeInsets.all(2),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7,
                children: List.generate(
                  materialItems.length,
                  (index) => GestureDetector(
                    onTap: () => _showItemDialog(context, materialItems[index]),
                    child: Container(
                      height: double.infinity,
                      // backgroundColor: Colors.white,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color.fromARGB(60, 46, 64, 83), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: (materialItems[index].images.first).startsWith('http')
                                  ? Image.network(
                                      materialItems[index].images.first,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      cacheHeight: 1000,
                                      cacheWidth: 600,
                                    )
                                  : Image.asset(
                                      materialItems[index].images.first,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      // Good cache height and width for images
                                      cacheHeight: 1000,
                                      cacheWidth: 600,
                                    ),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.0001),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              materialItems[index].title,
                              style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              '\$${_formatPrice(materialItems[index].price)}',
                              style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: const Color.fromARGB(255, 138, 136, 136)),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: Text('No items found'));
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        //BackgroundColor white and selected item color orange and black font
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
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView( // Add this
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.images.isNotEmpty)
                    Image.network(
                      item.images.first,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      cacheHeight: 1000,
                      cacheWidth: 600,
                    ),
                  const SizedBox(height: 8.0),
                  Text('Description: ${item.description}'),
                  const SizedBox(height: 8.0),
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