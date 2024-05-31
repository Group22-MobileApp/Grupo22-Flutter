import 'dart:async';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:goatsmart/models/user.dart';
import 'package:goatsmart/pages/addMaterial.dart';
import 'package:goatsmart/pages/itemGallery.dart';
import 'package:goatsmart/pages/likedItems.dart';
import 'package:goatsmart/pages/userProfile.dart';
import 'package:goatsmart/services/firebase_auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goatsmart/models/materialItem.dart';
import 'package:goatsmart/services/firebase_service.dart';
import 'package:connectivity/connectivity.dart';

class EditMaterialItemView extends StatefulWidget {
  final User userLoggedIn;
  final MaterialItem materialItem;

  const EditMaterialItemView({Key? key, required this.userLoggedIn, required this.materialItem}) : super(key: key);

  @override
  _EditMaterialItemViewState createState() => _EditMaterialItemViewState(userLoggedIn, materialItem);
}

class _EditMaterialItemViewState extends State<EditMaterialItemView> {
  final User userLoggedIn;
  final MaterialItem materialItem;

  _EditMaterialItemViewState(this.userLoggedIn, this.materialItem);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _auth = AuthService();
  
  bool _isNew = true;
  bool _isUsed = false;
  bool _isInterchangeable = false;
  bool _isNonInterchangeable = true;
  bool _isPosting = false;
  List<String> selectedCategories = [];  
  File? _image;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _titleController.text = materialItem.title;
    _descriptionController.text = materialItem.description;
    _priceController.text = materialItem.price.toString();
    _isNew = materialItem.condition == 'New';
    _isUsed = materialItem.condition == 'Used';
    _isInterchangeable = materialItem.interchangeable == 'Yes';
    _isNonInterchangeable = materialItem.interchangeable == 'No';
    selectedCategories = materialItem.categories;       
  }  

  List<String> categories = [
    'Textbooks', 'Notebooks', 'Stationery', 'Electronics', 'Clothing', 
    'Accessories', 'Furniture', 'Sports Equipment', 'Musical Instruments',
    'Art Supplies', 'Kitchenware', 'Home Appliances', 'Tools', 'Beauty & Personal Care',
    'Health & Fitness', 'Toys & Games', 'Pet Supplies', 'Outdoor Gear', 'Vehicles', 
    'Services', 'Tickets', 'Events', 'Miscellaneous', 'Bottles & Containers',
    'Plants & Gardening', 'Food & Beverages', 'Books & Magazines', 'Movies & Music',
    'Video Games', 'Board Games', 'Others'
  ];

  void selectCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

Future<bool> _checkConnectivity() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    return false;
  }
  return true;
}

void _onItemTapped(int index) async {
  bool isConnected = await _checkConnectivity();
  if (!isConnected) {
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
    // Navegación basada en el índice seleccionado
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ItemGallery()));
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LikedItemsGallery()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AddMaterialItemView(userLoggedIn: userLoggedIn)));
    } else if (index == 3) {
      // Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatView()));
    } else if (index == 4) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfile(user: userLoggedIn)));
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Post'),
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
                child: _image == null ? materialItem.images.isNotEmpty ? Stack(
                      children: [
                        Image.network(materialItem.images[0], fit: BoxFit.cover, width: double.infinity),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white, size: 30),
                            onPressed: () {
                              _showImagePicker(context);
                            },
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Take or add a photo",
                          style: TextStyle(
                            color: Color.fromARGB(210, 158, 158, 158),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        DottedBorder(
                          color: const Color.fromARGB(255, 67, 93, 122),
                          strokeWidth: 2,
                          borderType: BorderType.Circle,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: IconButton(
                              icon: const Icon(Icons.add_a_photo,
                                  color: Color.fromARGB(255, 67, 93, 122), size: 60),
                              onPressed: () {
                                _showImagePicker(context);
                              },
                            ),
                          ),
                        ),
                      ],
                    )
              : Stack(
                  children: [
                    Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 30),
                        onPressed: () {
                          _showImagePicker(context);
                        },
                      ),
                    ),
                  ],
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
                    SizedBox(width: 20),
                    Icon(
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Select Condition:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isNew,
                    onChanged: (value) {
                      setState(() {
                        _isNew = value!;
                        if (_isNew) _isUsed = false;
                      });
                    },
                  ),
                  const Text('New'),
                  const SizedBox(width: 20),
                  Checkbox(
                    value: _isUsed,
                    onChanged: (value) {
                      setState(() {
                        _isUsed = value!;
                        if (_isUsed) _isNew = false;
                      });
                    },
                  ),
                  const Text('Used'),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Interchangeable:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isInterchangeable,
                    onChanged: (value) {
                      setState(() {
                        _isInterchangeable = value!;
                        if (_isInterchangeable) _isNonInterchangeable = false;
                      });
                    },
                  ),
                  const Text('Yes'),
                  const SizedBox(width: 20),
                  Checkbox(
                    value: _isNonInterchangeable,
                    onChanged: (value) {
                      setState(() {
                        _isNonInterchangeable = value!;
                        if (_isNonInterchangeable) _isInterchangeable = false;
                      });
                    },
                  ),
                  const Text('No'),
                ],
              ),
              const SizedBox(height: 16),
              _isPosting ? const CircularProgressIndicator(): 
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),                                        
                    color: const Color(0xFFF7DC6F),
                  ),
                  child: ElevatedButton(
                    onPressed: _postMaterial,
                    style: ElevatedButton.styleFrom(                      
                      backgroundColor: const Color(0xFFF7DC6F),
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Update Item'
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
  

  
  Future<void> _postMaterial() async {
    setState(() {
      _isPosting = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isPosting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('No Internet Connection. Please check your internet connection and try again.'),
        ),
      );
      return;
    }

    final user = await _auth.getCurrentUserId();

    String title = _titleController.text;
    String description = _descriptionController.text;
    double price = double.tryParse(_priceController.text) ?? 0.0;
    String condition = _isNew ? 'New' : 'Used';
    String interchangeable = _isInterchangeable ? 'Yes' : 'No';
    List<String> categories = selectedCategories;
    
    String imageUrl = materialItem.images.isNotEmpty ? materialItem.images[0] : '';
    if (_image != null) {
      imageUrl = await _firebaseService.uploadImage(_image!);
    }

    MaterialItem updatedMaterialItem = MaterialItem(
      id: materialItem.id,
      title: title,
      description: description,
      price: price,
      condition: condition,
      interchangeable: interchangeable,
      images: [imageUrl],
      categories: categories,
      owner: user,
      views: materialItem.views,
      likes: materialItem.likes,
      likedBy: materialItem.likedBy,        
    );

    await _firebaseService.updateMaterialItem(updatedMaterialItem);
    setState(() {
      _isPosting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,          
        content: Text('Item updated successfully')),      
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ItemGallery()),
    );
    }
}
