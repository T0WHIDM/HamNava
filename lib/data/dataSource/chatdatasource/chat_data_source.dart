import 'package:flutter_chat_room_app/data/dtos/conversation_dto.dart';
import 'package:flutter_chat_room_app/data/dtos/message_dto.dart';

abstract class IChatDataSource {
  // ==================== Chats ====================

  Future<List<ConversationDto>> getAllChats();

  Future<List<ConversationDto>> searchChat(String chatId);

  Future<ConversationDto> createGroupChat(String chatName, String chatId);

  Future<void> deleteChat(String chatId);

  // ==================== Messages ====================

  Future<List<MessageDto>> getMessages(String chatId, {int page = 1});

  Future<List<MessageDto>> searchMessage(String chatId, String text);

  Future<MessageDto> sendMessage({
    required String text,
    required String chatId,
    // String? attachmentUrl,
  });

  Stream<MessageDto> listenToMessages(String chatId);

  Future<void> deleteMessage(String messageId);

  Future<MessageDto> editMessage({
    required String messageId,
    required String newText,
  });
}
