import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;

  MessageBubble({required this.text, required this.sender});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          sender == 'you' ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: sender == 'you' ? Colors.blue : Colors.grey[300],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: sender == 'you' ? Radius.circular(0) : Radius.circular(12),
              bottomRight: sender == 'you' ? Radius.circular(12) : Radius.circular(0),
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Text(
            text,
            style: TextStyle(
              color: sender == 'you' ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}