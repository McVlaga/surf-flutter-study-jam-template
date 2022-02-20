import 'package:flutter/material.dart';
import 'package:surf_practice_chat_flutter/data/chat/models/message.dart';
import 'package:surf_practice_chat_flutter/data/chat/repository/firebase.dart';

import 'package:surf_practice_chat_flutter/data/chat/repository/repository.dart';

/// Chat screen templete. This is your starting point.
class ChatScreen extends StatefulWidget {
  final ChatRepository chatRepository;

  const ChatScreen({
    Key? key,
    required this.chatRepository,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool loading = true;
  List<ChatMessageDto> _messages = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    _messages = await widget.chatRepository.messages;
    loading = false;
    setState(() {});
  }

  void _refreshPage() {
    loading = true;
    setState(() {});
    _fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: MainAppBar(onRefresh: _refreshPage),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : MessagesListWidget(messages: _messages),
    );
  }
}

class MainAppBar extends StatelessWidget {
  const MainAppBar({required this.onRefresh, Key? key}) : super(key: key);

  final void Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: MediaQuery.of(context).viewPadding.top,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter nickname',
              ),
            ),
          ),
          IconButton(onPressed: onRefresh, icon: Icon(Icons.refresh))
        ],
      ),
    );
  }
}

class MessagesListWidget extends StatelessWidget {
  const MessagesListWidget({
    Key? key,
    required List<ChatMessageDto> messages,
  })  : _messages = messages,
        super(key: key);

  final List<ChatMessageDto> _messages;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _messages.length,
      itemExtent: 60,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.deepPurple,
            child: Text(message.author.name[0]),
          ),
          title: Text(message.author.name),
          subtitle: Text(message.message),
        );
      },
    );
  }
}
