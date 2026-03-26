import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';

abstract class ChatEvent {}

class LoadMessagesEvent extends ChatEvent {
  final String chatId;

  LoadMessagesEvent(this.chatId);
}

class SendMessageEvent extends ChatEvent {
  final String chatId;
  final String text;

  SendMessageEvent({required this.chatId, required this.text});
}

class ChatInitializeEvent extends ChatEvent {
  final String targetUserId;
  ChatInitializeEvent(this.targetUserId);
}

class ChatMessageReceivedFromStreamEvent extends ChatEvent {
  final String action;
  final MessageEntity message;

  ChatMessageReceivedFromStreamEvent({
    required this.action,
    required this.message,
  });
}

class DeleteMessageEvent extends ChatEvent {
  final String messageId;
  final String chatId;

  DeleteMessageEvent(this.messageId, this.chatId);
}

class GetChatListEvent extends ChatEvent {
  final String userId;

  GetChatListEvent(this.userId);
}

class EditMessageEvent extends ChatEvent {
  final String newText;
  final String messageId;

  EditMessageEvent(this.messageId, this.newText);
}
