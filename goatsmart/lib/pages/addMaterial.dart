import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:goatsmart/services/firebase_auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goatsmart/models/materialItem.dart';
import 'package:goatsmart/services/firebase_service.dart';

class AddMaterialItemView extends StatefulWidget {
  const AddMaterialItemView({Key? key}) : super(key: key);

  @override
  _AddMaterialItemViewState createState() => _AddMaterialItemViewState();
}

class _AddMaterialItemViewState extends State<AddMaterialItemView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _auth = AuthService();  
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create a post'),
        backgroundColor: Colors.white,
        elevation: 0,
        // Bold and bigger
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
                color: Color.fromARGB(21, 133, 133, 133),
                borderRadius: BorderRadius.circular(90),
              ),
            child: _image == null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Take or add a photo",              
                        style: TextStyle(color: Color.fromARGB(210, 158, 158, 158), fontSize: 16, fontWeight: FontWeight.bold),              
                      ),
                      SizedBox(width: 10),
                      DottedBorder(
                        color: Color.fromARGB(255, 67, 93, 122),
                        strokeWidth: 2,
                        borderType: BorderType.Circle,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: IconButton(
                            icon: Icon(Icons.add_a_photo, color: Color.fromARGB(255, 67, 93, 122), size: 60),
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
                    color: Color.fromARGB(21, 133, 133, 133),
                  ),
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
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
                    color: Color.fromARGB(21, 133, 133, 133),
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
                    color: Color.fromARGB(21, 133, 133, 133),
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
                      color: const Color(0xFF2E4053),
                    ),),
                  ),
                ),
              ),              
            ],                        
          ),
        ),
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
  
  void _addMaterialItem(BuildContext context) {
    String title = _titleController.text;
    String description = _descriptionController.text;
    double price = double.tryParse(_priceController.text) ?? 0.0;
        
    String currentUserId = _auth.getCurrentUserId();

    if (title.isNotEmpty && description.isNotEmpty && price > 0) {
      MaterialItem newItem = MaterialItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        price: price,
        images: _image != null ? [_image!.path] : [],
        owner: currentUserId, 
      );

      _firebaseService.createMaterialItem(newItem).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material item added successfully')),
        );
        _titleController.clear();
        _descriptionController.clear();
        _priceController.clear();
        setState(() {
          _image = null;
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add material item: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }
}
