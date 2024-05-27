import 'package:flutter/material.dart';
import 'package:goatsmart/services/chat_Service.dart';
import 'package:goatsmart/services/firebase_service.dart';

class HomeChat extends StatefulWidget {
  static String id = 'home_chat';
  const HomeChat({Key? key}) : super(key: key);

  @override
  _HomeChatState createState() => _HomeChatState();
}

class _HomeChatState extends State<HomeChat> {

  final FirebaseService _firebaseService = FirebaseService();
  List<String> users = [];

  @override
  void initState() {
    super.initState();
    _firebaseService.getAllUserEmails().then((emails) {
      setState(() {
        users = emails;
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Messages'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(users[index]),
            tileColor: Colors.white,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatService(receiver: users[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}