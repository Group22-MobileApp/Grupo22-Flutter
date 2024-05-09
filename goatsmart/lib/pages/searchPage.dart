import 'package:flutter/material.dart';
import 'package:goatsmart/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

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
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
  final prefs = await SharedPreferences.getInstance();
  final storedSearches = prefs.getStringList('recentSearches');
  if (storedSearches != null) {
    setState(() {
      recentSearches = storedSearches;
    });
  }
}
  void _fetchPopularSearches() async {
    // Fetch the post with more views from the database
    List<dynamic> posts = await _firebaseService.getPosts();
    print("Posts: $posts");
    posts.sort((a, b) => b['views'].compareTo(a['views']));
    setState(() {
      popularSearches =
          posts.sublist(0, 3).map((post) => post['title'] as String).toList();
    });
  }

  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recentSearches', recentSearches);
  }

  void _addRecentSearch(String search) async {
    if (!recentSearches.contains(search)) {
      setState(() {
        recentSearches.insert(0, search);
        if (recentSearches.length > 3) {
          recentSearches.removeLast();
        }
      });
      await _saveRecentSearches();
    }
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
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> searchProduct(String product) async {
    List<dynamic> items = await _firebaseService.getPostByTitle(product);
    if (items.isEmpty) {
      // Show a snackbar if the product is not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product not found'),
        ),
      );
    }
    _addRecentSearch(product);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Search Results'),
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
                    _firebaseService.addView(items[index]["title"]);
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
        title: const Text('Search'),
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
                        icon: const Icon(
                          Icons.search,
                        ),
                        onPressed: () {
                          searchProduct(searchController.text);
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
                const ListTile(
                  title: Text('Recent Searches'),
                ),
                for (String search in recentSearches)
                  ListTile(
                    title: Text(search),
                    onTap: () => searchProduct(search),
                  ),
                const ListTile(
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
