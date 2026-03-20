import 'package:flutter_chat_room_app/data/dtos/conversation_dto.dart';
import 'package:flutter_chat_room_app/data/dtos/message_dto.dart';

abstract class IChatDatasource {
  // ==================== Chats ====================

  Future<List<ConversationDto>> getAllChats();

  Future<ConversationDto> getChatById(String chatId);

  Future<ConversationDto> createGroupChat({
    required String chatName,
    required List<String> participantIds,
  });

  Future<ConversationDto> createOrGetPrivateChat(String targetUserId);

  Future<void> deleteChat(String chatId);

  // ==================== Messages ====================

  Future<List<MessageDto>> getMessages(String chatId, {int page = 1});

  Future<List<MessageDto>> searchMessage(String chatId, String text);

  Future<MessageDto> sendMessage({
    required String chatId,
    String? text,
    // File? attachment, //
  });

  Stream<MessageDto> listenToMessages(String chatId);

  Future<void> deleteMessage(String messageId);

  Future<MessageDto> editMessage({
    required String messageId,
    required String newText,
  });
}
