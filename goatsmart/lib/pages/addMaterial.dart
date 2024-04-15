import 'dart:io';

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
      appBar: AppBar(
        title: const Text('Add New Material Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _image == null
                ? ElevatedButton(
                    onPressed: () {
                      _showImagePicker(context);
                    },
                    child: const Text('Add Picture'),
                  )
                : Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: Image.file(_image!),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _showImagePicker(context);
                        },
                        child: const Text('Change Picture'),
                      ),
                    ],
                  ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _addMaterialItem(context),
              child: const Text('Add Material Item'),
            ),
          ],
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