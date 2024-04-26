import 'package:flutter/material.dart';
import 'package:goatsmart/models/materialItem.dart';
import 'package:goatsmart/services/firebase_service.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FirebaseService _firebaseService = FirebaseService();
  TextEditingController searchController = TextEditingController();

  List<String> recentSearches = [];
  List<String> popularSearches = [];

  @override
  void initState() {
    super.initState();
    _fetchPopularSearches();
  }

  void _fetchPopularSearches() async {
    List searches = await _firebaseService.fetchLastItemsTittle();
    setState(() {
      popularSearches = searches.cast<String>();
    });
  }

  void _showItemDialog(BuildContext context, var item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(item['title']),
          content: Column(
            children: [
              Image.network(item['images'][0]),
              Text(item['description']),
              Text('Price: \$${item['price']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

Future<void> searchProduct(String product) async {
  List<dynamic> items = await _firebaseService.getPostByTitle(product);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Search Results'),
          ),
          backgroundColor: Colors.white,
          body: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(items[index]['images'][0]),
                ),
                title: Text(items[index]['title']),
                subtitle: Text(items[index]['description']),
                onTap: () {
                  _showItemDialog(context, items[index]);
                },
              );
            },
          ),
        );
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      suffixIcon: IconButton(
                      icon: Icon(
                         Icons.search ,
                      ),
                      onPressed: () {
                        searchProduct( searchController.text);
                      },
                    ),
                    ),
                    onSubmitted: searchProduct,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text('Recent Searches'),
                ),
                for (String search in recentSearches)
                  ListTile(
                    title: Text(search),
                    onTap: () => searchProduct(search),
                  ),
                ListTile(
                  title: Text('Popular Searches'),
                ),
                for (String search in popularSearches)
                  ListTile(
                    title: Text(search),
                    onTap: () => searchProduct(search),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
