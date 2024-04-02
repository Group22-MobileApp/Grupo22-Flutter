import 'package:flutter/material.dart';

class ItemGallery extends StatefulWidget {
  static const String routeName = 'ItemGallery';
  const ItemGallery({Key? key}) : super(key: key);

  @override
  _ItemGallery createState() => _ItemGallery();
}

class _ItemGallery extends State<ItemGallery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Gallery'),
      ),
      body: ListView(
        children: <Widget>[
          Image.asset('assets/images/1.jpg'),
          Image.asset('assets/images/2.jpg'),
          Image.asset('assets/images/3.jpg'),
          Image.asset('assets/images/4.jpg'),
          Image.asset('assets/images/5.jpg'),
          Image.asset('assets/images/6.jpg'),
          Image.asset('assets/images/7.jpg'),
          Image.asset('assets/images/8.jpg'),
          Image.asset('assets/images/9.jpg'),
          Image.asset('assets/images/10.jpg')          
        ],
      ),
    );
  }
}
