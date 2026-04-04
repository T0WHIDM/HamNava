import 'dart:io';

import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';

abstract class ChatEvent {}

class LoadMessagesEvent extends ChatEvent {
  final String chatId;

  LoadMessagesEvent(this.chatId);
}

class SendMessageEvent extends ChatEvent {
  final String chatId;
  final String? text;
  final String? replyId;
  final File? attachment;

  SendMessageEvent({
    required this.chatId,
    this.text,
    this.replyId,
    this.attachment,
  });
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

class DeleteChatEvent extends ChatEvent {
  final String chatId;

  DeleteChatEvent(this.chatId);
}

class CreateGroupChatEvent extends ChatEvent {
  final String chatName;
  final List<UserEntity> participants;

  CreateGroupChatEvent({required this.chatName, required this.participants});
}

class AddFriendToGroupEvent extends ChatEvent {
  final String chatId;
  final String userId;

  AddFriendToGroupEvent(this.chatId, this.userId);
}

class LeaveFromGroupEvent extends ChatEvent {
  final String chatId;
  final String userId;

  LeaveFromGroupEvent(this.chatId, this.userId);
}

class LoadMoreMessagesEvent extends ChatEvent {
  final String chatId;
  final int page;

  LoadMoreMessagesEvent({required this.chatId, required this.page});
}
