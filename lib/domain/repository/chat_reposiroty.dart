import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';

abstract class IChatRepository {
  // ==================== Chats ====================

  Future<Either<ApiException, List<ConversationEntity>>> getAllChats();

  Future<Either<ApiException, List<ConversationEntity>>> searchChat(
    String chatId,
  );

  Future<Either<ApiException, ConversationEntity>> createGroupChat(
    String chatName,
    String chatId,
  );

  Future<Either<ApiException, void>> deleteChat(String chatId);

  // ==================== Messages ====================

  Future<Either<ApiException, List<MessageEntity>>> getMessages(
    String chatId, {
    int page = 1,
  });

  Future<Either<ApiException, List<MessageEntity>>> searchMessage(
    String chatId,
    String text,
  );

  Future<Either<ApiException, MessageEntity>> sendMessage({
    required String text,
    required String chatId,
    // String? attachmentUrl,
  });

  Stream<MessageEntity> listenToMessages(String chatId);

  Future<Either<ApiException, void>> deleteMessage(String messageId);

  Future<Either<ApiException, MessageEntity>> editMessage({
    required String messageId,
    required String newText,
  });
}
