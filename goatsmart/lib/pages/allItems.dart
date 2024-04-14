import 'package:flutter/material.dart';
import 'package:goatsmart/models/materialItem.dart';
import 'package:goatsmart/services/firebaseService.dart';

class SeeAllItemsView extends StatefulWidget {
  @override
  _SeeAllItemsViewState createState() => _SeeAllItemsViewState();
}

class _SeeAllItemsViewState extends State<SeeAllItemsView> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<MaterialItem>> _materialItemsFuture;

  @override
  void initState() {
    super.initState();
    _materialItemsFuture = _firebaseService.getMaterialItemsNameDescription();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Items'),
      ),
      body: FutureBuilder<List<MaterialItem>>(
        future: _materialItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<MaterialItem> materialItems = snapshot.data!;
            return ListView.builder(
              itemCount: materialItems.length,
              itemBuilder: (context, index) {
                MaterialItem item = materialItems[index];
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.description),
                  leading: item.images.isNotEmpty
                      ? Image.network(
                          item.images.first, 
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Container(), 
                );
              },
            );
          } else {
            return Center(child: Text('No items found'));
          }
        },
      ),
    );
  }
}
