import 'dart:io';

import 'package:flutter_chat_room_app/data/dtos/conversation_dto.dart';
import 'package:flutter_chat_room_app/data/dtos/message_dto.dart';

abstract class IChatDatasource {
  // ==================== Chats ====================

  Future<List<ConversationDto>> getAllChats();

  Future<ConversationDto> createOrGetGroupChat({
    required String chatName,
    required List<String> participantIds,
  });

  Future<ConversationDto> createOrGetPrivateChat(String targetUserId);

  Future<void> deleteChat(String chatId);

  Future<ConversationDto> addFriendToGroup(String userId, String chatId);

  Future<void> leaveFromGroup(String userId, String chatId);

  // ==================== Messages ====================

  Future<List<MessageDto>> getMessages(String chatId, {int page = 1});

  Future<MessageDto> sendMessage({
    required String chatId,
    String? text,
    String? replyId,
    File? attachment,
  });

  Stream<({String action, MessageDto message})> listenToMessages(String chatId);

  Future<void> deleteMessage(String messageId, String chatId);

  Future<MessageDto> editMessage({
    required String messageId,
    required String newText,
  });
}
