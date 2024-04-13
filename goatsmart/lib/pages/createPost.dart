import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goatsmart/services/firebase_service.dart';

class CreatePost extends StatefulWidget {
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final ImagePicker _imagePicker = ImagePicker();
  late PickedFile _pickedImage;

  Future<void> _pickImage() async {
    final pickedImage = await _imagePicker.getImage(source: ImageSource.gallery);
    setState(() {
      _pickedImage = pickedImage!;
    });
  }

  Future<void> _uploadPost() async {
    if (_pickedImage != null) {
      await addPost("null", "null", _pickedImage, "null");
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_pickedImage != null)
              Image.file(File(_pickedImage.path)),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            ElevatedButton(
              onPressed: _uploadPost,
              child: Text('Upload Post'),
            ),
          ],
        ),
      ),
    );
  }
}