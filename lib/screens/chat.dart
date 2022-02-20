import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_practice_chat_flutter/data/chat/models/message.dart';
import 'package:surf_practice_chat_flutter/data/chat/models/messages_list_model.dart';
import 'package:surf_practice_chat_flutter/data/chat/models/user.dart';

/// Chat screen templete. This is your starting point.
class ChatScreen extends StatefulWidget {
  final MessagesListModel model;

  const ChatScreen({
    Key? key,
    required this.model,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getMessages();
  }

  void _getMessages() {
    widget.model.fetchMessages();
  }

  void _sendMessage() {
    widget.model.sendMessage(_nameController.text, _messageController.text);
    _messageController.text = '';
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 2),
      content: Text(error),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: widget.model,
        builder: (context, model) {
          return Scaffold(
            appBar: AppBar(
              flexibleSpace: MainAppBar(
                controller: _nameController,
                onRefresh: _getMessages,
              ),
            ),
            body: Column(
              children: [
                const MessagesListWidget(),
                SendMessageBottomBar(
                  controller: _messageController,
                  onSendMessage: _sendMessage,
                ),
              ],
            ),
          );
        });
  }
}

class MainAppBar extends StatelessWidget {
  const MainAppBar(
      {required this.onRefresh, required this.controller, Key? key})
      : super(key: key);

  final void Function() onRefresh;
  final TextEditingController controller;

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
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter nickname',
              ),
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class MessagesListWidget extends StatelessWidget {
  const MessagesListWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder(
          future: context.read<MessagesListModel>().fetchMessages(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.done) {
              return Consumer<MessagesListModel>(builder: (context, model, _) {
                List<ChatMessageDto> messages = model.messages;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    bool local = false;
                    if (message.author is ChatUserLocalDto) {
                      local = true;
                    }
                    return Container(
                      color: local ? Colors.deepPurple[50] : Colors.transparent,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: Text(message.author.name[0]),
                        ),
                        title: Text(message.author.name),
                        subtitle: Text(message.message),
                      ),
                    );
                  },
                );
              });
            }
            return SizedBox.shrink();
          }),
    );
  }
}

class SendMessageBottomBar extends StatelessWidget {
  const SendMessageBottomBar({
    Key? key,
    required this.onSendMessage,
    required this.controller,
  }) : super(key: key);

  final void Function() onSendMessage;
  final TextEditingController controller;

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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Message',
              ),
            ),
          ),
          IconButton(
            onPressed: onSendMessage,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
