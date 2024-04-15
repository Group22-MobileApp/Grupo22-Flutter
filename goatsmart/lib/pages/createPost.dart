import 'dart:io';

import 'package:flutter/material.dart';
import 'package:goatsmart/services/firebase_service.dart';
import 'package:image_picker/image_picker.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({Key? key}) : super(key: key);
  
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseService _firebaseService = FirebaseService();
  late PickedFile _pickedImage;

  Future<void> _pickImage() async {
    final pickedImage = await _imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _pickedImage = pickedImage! as PickedFile;
    });
  }

  Future<void> _uploadPost() async {
    await _firebaseService.addPost("null", "null", _pickedImage, "null");
    
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(File(_pickedImage.path)),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            ElevatedButton(
              onPressed: _uploadPost,
              child: const Text('Upload Post'),
            ),
          ],
        ),
      ),
    );
  }
}