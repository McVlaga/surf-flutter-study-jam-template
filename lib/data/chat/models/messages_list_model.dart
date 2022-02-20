import 'package:flutter/material.dart';
import 'package:surf_practice_chat_flutter/data/chat/models/message.dart';
import 'package:surf_practice_chat_flutter/data/chat/repository/repository.dart';

class MessagesListModel with ChangeNotifier {
  MessagesListModel(this._chatRepository);

  final ChatRepository _chatRepository;
  List<ChatMessageDto> _messages = [];

  List<ChatMessageDto> get messages => _messages;

  Future<void> fetchMessages() async {
    try {
      _messages = await _chatRepository.messages;
      notifyListeners();
    } catch (e) {}
  }

  Future<void> sendMessage(String name, String message) async {
    try {
      _messages = await _chatRepository.sendMessage(name, message);
      notifyListeners();
    } on InvalidMessageException catch (e) {
    } on InvalidNameException catch (e) {
    } catch (e) {}
  }
}
