import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goatsmart/services/control_features.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goatsmart/pages/itemGallery.dart';

class ChatService extends StatefulWidget {
  static String id = 'chat_service';
  final String receiver;
  const ChatService({Key? key, required this.receiver})
      : super(key: key);

  @override
  _ChatServiceState createState() => _ChatServiceState();
}

class _ChatServiceState extends State<ChatService> {
  final _controlFeatures = ConnectionManager();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late User loggedInUser;
  late String messagetext;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerText = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ItemGallery()));
              }),
        ],
        title: const Text('Home Chat'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder(
                stream: _firestore
                    .collection("messages")
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    final message = (snapshot.data as QuerySnapshot)
                        .docs
                        .where((element) =>
                            (element['receiver'] == loggedInUser.email &&
                                element['sender'] == widget.receiver) ||
                            (element['sender'] == loggedInUser.email &&
                                element['receiver'] == widget.receiver))
                        .toList();
                    List<MessageBubble> messageWidgets = [];
                    for (var msg in message) {
                      final messageText = msg['text'];
                      final messageSender = msg['sender'];
                      final currentUser = loggedInUser.email;
                      messageWidgets.add(MessageBubble(
                        text: messageText,
                        sender: messageSender,
                        isMe: currentUser == messageSender,
                      ));
                    }
                    return Expanded(
                      child: ListView(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 20.0),
                        children: messageWidgets,
                      ),
                    );
                  }
                }),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                      color: Color.fromARGB(255, 139, 139, 139), width: 2.0),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: controllerText,
                      onChanged: (value) {
                        messagetext = value;
                      },
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 1.0, horizontal: 2.0),
                        hintText: 'Type your message here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (!await _controlFeatures.checkInternetConnection()) {
                        print("Internet is not connected");
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('No Network Connection! '),
                              backgroundColor: Colors.white,
                              content: const Text(
                                  'No hay conexion a internet, por favor revisa tu red e intenta nuevamente.'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      } else {
                        controllerText.clear();
                        _firestore.collection("messages").add({
                          'text': messagetext,
                          'sender': loggedInUser.email,
                          'createdAt': FieldValue.serverTimestamp(),
                          "receiver": widget.receiver,
                        });
                      }
                    },
                    child: const Text(
                      'Send',
                      style: TextStyle(
                        color: Color.fromARGB(255, 95, 95, 95),
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final bool isMe;

  const MessageBubble(
      {Key? key, required this.text, required this.sender, required this.isMe})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(sender,
            style: const TextStyle(fontSize: 12.0, color: Colors.black54)),
        Material(
          borderRadius: BorderRadius.only(
            topLeft:
                isMe ? const Radius.circular(30.0) : const Radius.circular(0.0),
            topRight:
                isMe ? const Radius.circular(0.0) : const Radius.circular(30.0),
            bottomLeft: const Radius.circular(30.0),
            bottomRight: const Radius.circular(30.0),
          ),
          elevation: 5.0,
          color: isMe
              ? const Color.fromARGB(255, 206, 209, 210)
              : const Color.fromARGB(255, 255, 225, 0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: Text(
              text,
              style: TextStyle(
                color: isMe ? const Color.fromARGB(255, 0, 0, 0) : Colors.black54,
                fontSize: 15.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
