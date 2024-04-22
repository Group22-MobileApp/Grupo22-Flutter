import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goatsmart/models/materialItem.dart';
import 'package:goatsmart/models/user.dart';
import 'package:goatsmart/services/firebase_service.dart';
import 'package:intl/intl.dart'; 

class SeeAllItemsView extends StatefulWidget {
  const SeeAllItemsView({Key? key}) : super(key: key);

  @override
  _SeeAllItemsViewState createState() => _SeeAllItemsViewState();
}

class _SeeAllItemsViewState extends State<SeeAllItemsView> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<MaterialItem>> _materialItemsFuture;

  @override
  void initState() {
    super.initState();
    _materialItemsFuture = _firebaseService.getMaterialItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Items'),
      ),
      body: FutureBuilder<List<MaterialItem>>(
        future: _materialItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<MaterialItem> materialItems = snapshot.data!;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: materialItems.length,
              itemBuilder: (context, index) {
                MaterialItem item = materialItems[index];
                return GestureDetector(
                  onTap: () => _showItemDialog(context, item),
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                            child: item.images.isNotEmpty
                                ? Image.network(
                                    item.images.first,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Container(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              Text(
                                item.description,
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Price: \$${_formatPrice(item.price)}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No items found'));
          }
        },
      ),
    );
  }


  String _formatPrice(double price) {
    String formattedPrice = price.toStringAsFixed(2);
    return NumberFormat.currency(locale: 'en_US', symbol: '').format(double.parse(formattedPrice));
  }

  Future<void> _showItemDialog(BuildContext context, MaterialItem item) async {            
    User? user = await _firebaseService.getUser(item.owner);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(item.title),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.images.isNotEmpty)
                  Image.network(
                    item.images.first,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                SizedBox(height: 8.0),
                Text('Description: ${item.description}'),
                SizedBox(height: 8.0),
                Text('Price: \$${_formatPrice(item.price)}', style: TextStyle(fontWeight: FontWeight.bold)),
                if (user != null) ...[
                  SizedBox(height: 8.0),                  
                  Text('Owner username: ${user.username}'),
                  Text('Owner name: ${user.name}'),
                  Text('Email: ${user.email}'),                  
                  Text('Career: ${user.carrer}'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

}