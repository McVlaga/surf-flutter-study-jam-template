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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

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

  Future<void> _sendMessage() async {
    loading = true;
    setState(() {});
    _messages = await widget.chatRepository
        .sendMessage(_nameController.text, _messageController.text);
    _messageController.text = '';
    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace:
            MainAppBar(onRefresh: _refreshPage, controller: _nameController),
      ),
      body: Column(
        children: [
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : MessagesListWidget(
                    messages: _messages,
                  ),
          ),
          SendMessageBottomBar(
            controller: _messageController,
            onSendMessage: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class SendMessageBottomBar extends StatelessWidget {
  SendMessageBottomBar({
    Key? key,
    required this.onSendMessage,
    required this.controller,
  }) : super(key: key);

  final void Function() onSendMessage;
  TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 16, bottom: 40),
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Message',
              ),
            ),
          ),
          IconButton(
            onPressed: onSendMessage,
            icon: Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

class MainAppBar extends StatelessWidget {
  MainAppBar({required this.onRefresh, required this.controller, Key? key})
      : super(key: key);

  final void Function() onRefresh;
  TextEditingController controller;

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
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter nickname',
              ),
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: Icon(Icons.refresh),
          ),
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
      reverse: true,
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
