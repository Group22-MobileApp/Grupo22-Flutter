import 'dart:io';

import 'package:flutter/material.dart';
import 'package:goatsmart/services/firebase_auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goatsmart/models/materialItem.dart';
import 'package:goatsmart/services/firebase_service.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:goatsmart/models/user.dart';
import 'package:goatsmart/pages/itemGallery.dart';
import 'package:goatsmart/pages/likedItems.dart';
import 'package:goatsmart/pages/userProfile.dart';
import 'package:connectivity/connectivity.dart';

class AddMaterialItemView extends StatefulWidget {
  final User userLoggedIn;
  const AddMaterialItemView({Key? key, required this.userLoggedIn}) : super(key: key);  
  @override
  _AddMaterialItemViewState createState() => _AddMaterialItemViewState(userLoggedIn);
}

class _AddMaterialItemViewState extends State<AddMaterialItemView> {
  User userLoggedIn;
  _AddMaterialItemViewState(this.userLoggedIn);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _auth = AuthService();  
  bool _isNew = true;
  bool _isUsed = false;
  bool _isInterchangeable = false ;
  bool _isNonInterchangeable = true;
  bool _isPosting = false;
  List<String> selectedCategories = [];

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

  
  File? _image;

  int _selectedIndex = 0;
  void selectCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category); 
      } else {
        selectedCategories.add(category); 
      }
    });
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
                builder: (context) => AddMaterialItemView(userLoggedIn: userLoggedIn)));
      } else if (index == 3) {
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatView()));
      } else if (index == 4) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserProfile(user: userLoggedIn)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create a post'),
        backgroundColor: Colors.white,
        elevation: 0,        
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(220, 0, 0, 0),
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
              height: MediaQuery.of(context).size.height / 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(21, 133, 133, 133),
                borderRadius: BorderRadius.circular(90),
              ),
              child: _image == null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Take or add a photo",              
                        style: TextStyle(color: Color.fromARGB(210, 158, 158, 158), fontSize: 16, fontWeight: FontWeight.bold),              
                      ),
                      const SizedBox(width: 10),
                      DottedBorder(
                        color: const Color.fromARGB(255, 67, 93, 122),
                        strokeWidth: 2,
                        borderType: BorderType.Circle,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: IconButton(
                            icon: const Icon(Icons.add_a_photo, color: Color.fromARGB(255, 67, 93, 122), size: 60),
                            onPressed: () {
                              _showImagePicker(context);
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                    : Image.file(_image!, fit: BoxFit.cover),
                ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(                
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: const Color.fromARGB(21, 133, 133, 133),
                  ),
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),                  
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: const Color.fromARGB(21, 133, 133, 133),
                  ),
                  child: TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),                      
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: const Color.fromARGB(21, 133, 133, 133),
                  ),
                  child: TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),                
              ),   
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    Text(
                      'Tap to select categories:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // left padding little
                    SizedBox(width: 20),                                                                
                    Icon(
                      // Tap icon)
                      Icons.auto_awesome_motion_outlined,
                      size: 30,                                                                  
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 200,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 4,
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
              ),
              const SizedBox(height: 16),
                Row(
                  children: [                  
                    SizedBox(        
                      width: MediaQuery.of(context).size.width / 2 -16, 
                      child: Expanded(                                                                                    
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Condition', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                              CheckboxListTile(
                                title: const Text('New'),
                                value: _isNew,
                                onChanged: (value) {
                                  setState(() {
                                    _isNew = value!;
                                    _isUsed = !value;
                                  });
                                },
                              ),
                              CheckboxListTile(
                                title: const Text('Used'),
                                value: _isUsed,
                                onChanged: (value) {
                                  setState(() {
                                    _isUsed = value!;
                                    _isNew = !value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(        
                      width: MediaQuery.of(context).size.width / 2 -16,                 
                      child: Expanded(                                                                                    
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Interchangeable', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                              CheckboxListTile(
                                title: const Text('Yes'),
                                value: _isInterchangeable,
                                onChanged: (value) {
                                  setState(() {
                                    _isInterchangeable = value!;
                                    _isNonInterchangeable = !value;
                                  });
                                },
                              ),
                              CheckboxListTile(
                                title: const Text('No'),
                                value: _isNonInterchangeable,
                                onChanged: (value) {
                                  setState(() {
                                    _isNonInterchangeable = value!;
                                    _isInterchangeable = !value;                                    
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),          
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),                                        
                    color: const Color(0xFFF7DC6F),
                  ),
                  child: ElevatedButton(
                    onPressed: () => _addMaterialItem(context),
                    style: ElevatedButton.styleFrom(                      
                      backgroundColor: const Color(0xFFF7DC6F),
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Post'
                    , style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                      color: Color(0xFF2E4053),
                    ),),
                  ),
                ),
              ),              
            ],                        
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(        
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
    void _showImagePicker(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await showModalBottomSheet<XFile>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Take a photo'),
                onTap: () async {
                  Navigator.pop(context, await picker.pickImage(source: ImageSource.camera));
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(context, await picker.pickImage(source: ImageSource.gallery));
                },
              ),
            ],
          ),
        );
      },
    );

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }
  

  void _addMaterialItem(BuildContext context) async {
    if (_isPosting) {
      return;
    }

    setState(() {
      _isPosting = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isPosting = false;
      });
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

    String title = _titleController.text;
    String description = _descriptionController.text;
    double price = double.tryParse(_priceController.text) ?? 0.0;

    String currentUserId = _auth.getCurrentUserId();

    if (title.isNotEmpty && description.isNotEmpty && price > 0 && _image != null) {
      MaterialItem newItem = MaterialItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        price: price,
        images: [_image!.path],
        owner: currentUserId,
        condition: _isNew ? 'New' : 'Used',
        interchangeable: _isInterchangeable ? 'Yes' : 'No',
        views: 0,
        categories: selectedCategories,
        likes: 0,
      );

      print("Categories: ${newItem.categories}");

      _firebaseService.createMaterialItem(newItem).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Material item added successfully')),
        );
        _titleController.clear();
        _descriptionController.clear();
        _priceController.clear();
        setState(() {
          _image = null;
        });

        // Navigate to ItemGallery
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ItemGallery()),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add material item: $error')),
        );
      }).whenComplete(() {
        Future.delayed(const Duration(seconds: 5), () {
          setState(() {
            _isPosting = false;
          });
        });
      });
    } else {
      String errorMessage = '';
      if (title.isEmpty) {
        errorMessage += 'Title is required. ';
      }
      if (description.isEmpty) {
        errorMessage += 'Description is required. ';
      }
      if (price <= 0) {
        errorMessage += 'Price must be greater than zero. ';
      }
      if (_image == null) {
        errorMessage += 'Please add a picture. ';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      setState(() {
        _isPosting = false;
      });
    }
  }
}
