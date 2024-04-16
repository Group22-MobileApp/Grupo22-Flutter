import 'package:flutter/material.dart';
import 'package:goatsmart/models/user.dart';

class UserProfile extends StatelessWidget {
  final User user;

  const UserProfile({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(user.imageUrl),
            ),
            SizedBox(height: 20),
            Text(
              'Username: ${user.username}',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Email: ${user.email}',
              style: TextStyle(fontSize: 20),
            ),            
          ],
        ),
      ),
    );
  }
}
