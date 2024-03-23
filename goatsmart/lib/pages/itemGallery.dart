import 'package:flutter/material.dart';

class ItemGallery extends StatefulWidget {
  const ItemGallery({Key? key}) : super(key: key);

  @override
  _ItemGalleryState createState() => _ItemGalleryState();
}

class _ItemGalleryState extends State<ItemGallery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Gallery'),
      ),
      body: const Center(
        child: Text('Item Gallery'),
      ),
    );
  }
}
