import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:goatsmart/models/materialItem.dart';
import 'package:goatsmart/models/user.dart';
import 'package:goatsmart/services/firebase_service.dart';
import 'package:intl/intl.dart';

class DialogService {
  final FirebaseService _firebaseService = FirebaseService();

  String _formatPrice(double price) {
    String formattedPrice = price.toStringAsFixed(2);
    return NumberFormat.currency(locale: 'en_US', symbol: '')
        .format(double.parse(formattedPrice));
  }
  
  Future<void> showItemDialog(BuildContext context, MaterialItem item, int rand) async {
    return _showItemDialog(context, item, rand);
  }

  Future<void> _showItemDialog(BuildContext context, MaterialItem item, int rand) async {
    User? user = await _firebaseService.getUser(item.owner);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(item.title),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.images.isNotEmpty && item.images.first.startsWith('http'))
                            CachedNetworkImage(
                              imageUrl: item.images.first,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              memCacheHeight: 800,
                              memCacheWidth: 600,
                              errorWidget: (context, error, stackTrace) {
                                return Image.asset('assets/images/$rand.jpg');
                              },
                            )
                          else
                            Image.asset(
                              item.images.first,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          const SizedBox(height: 8.0),
                          Text('Description: ${item.description}'),
                          Text('Categories: ${item.categories.join(', ')}'),                
                          Text('Condition: ${item.condition}'),
                          Text('Interchangeable: ${item.interchangeable}'),
                          Text('Views: ${item.views}'),
                          Text('Likes: ${item.likes}'),                  
                          Text('Price: \$${_formatPrice(item.price)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  if (user != null) ...[
                    const SizedBox(height: 16.0),
                    Card(
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Owner Information', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8.0),
                            CachedNetworkImage(
                              imageUrl: user.imageUrl,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              imageBuilder: (context, imageProvider) => Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              memCacheHeight: 300,
                              memCacheWidth: 220,
                              errorWidget: (context, error, stackTrace) {
                                return const Icon(Icons.person, size: 120);
                              },
                            ),
                            const SizedBox(height: 8.0),
                            Text('Username: ${user.username}'),
                            Text('Name: ${user.name}'),
                            Text('Email: ${user.email}'),
                            Text('Career: ${user.carrer}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context). pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}