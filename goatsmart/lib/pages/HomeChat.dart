import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatComponent extends StatefulWidget {
  final String firebaseUserId;

  const ChatComponent({Key? key, required this.firebaseUserId}) : super(key: key);

  @override
  _ChatComponentState createState() => _ChatComponentState();
}

class _ChatComponentState extends State<ChatComponent> {
  final _client = StreamChatClient(
    'YOUR_STREAM_API_KEY',
    logLevel: Level.INFO,
  );

  @override
  void initState() {
    super.initState();
    _connectToChat();
  }

  Future<void> _connectToChat() async {
    await _client.connectUser(
      User(
        id: widget.firebaseUserId,
      ),
      widget.firebaseUserId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamChat(
      client: _client,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
        ),
        body: Container(
          child: const Text('Chat'),
        ),
      ),
    );
  }
}

class ChannelListView {
}

class ChannelPage {
}

class ChannelListHeader {

}