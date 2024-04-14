import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goatsmart/models/materialItem.dart';
import 'package:goatsmart/services/firebaseService.dart';

class AddMaterialItemView extends StatefulWidget {
  @override
  _AddMaterialItemViewState createState() => _AddMaterialItemViewState();
}

class _AddMaterialItemViewState extends State<AddMaterialItemView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Material Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            _image == null
                ? ElevatedButton(
                    onPressed: () {
                      _showImagePicker(context);
                    },
                    child: Text('Add Picture'),
                  )
                : Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: Image.file(_image!),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _showImagePicker(context);
                        },
                        child: Text('Change Picture'),
                      ),
                    ],
                  ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _addMaterialItem(context),
              child: Text('Add Material Item'),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePicker(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await showModalBottomSheet<XFile>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Take a photo'),
                onTap: () async {
                  Navigator.pop(context, await _picker.pickImage(source: ImageSource.camera));
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(context, await _picker.pickImage(source: ImageSource.gallery));
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
    String title = _titleController.text;
    String description = _descriptionController.text;
    double price = double.tryParse(_priceController.text) ?? 0.0;

    if (title.isNotEmpty && description.isNotEmpty && price > 0 && _image != null) {
      MaterialItem newItem = MaterialItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        price: price,
        images: [_image!.path],
        owner: 'current_user_id',
      );

      try {
        await _firebaseService.createMaterialItem(newItem);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Material item added successfully')),
        );
        _titleController.clear();
        _descriptionController.clear();
        _priceController.clear();
        setState(() {
          _image = null;
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add material item: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select an image')),
      );
    }
  }
}
