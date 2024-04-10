import 'package:flutter/material.dart';
import 'package:goatsmart/services/firebase_service.dart';

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
        body: FutureBuilder(
          future: getPosts(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            if (snapshot.hasData) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index) {
                    return Text(snapshot.data?[index]['category']);
                  },
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}
