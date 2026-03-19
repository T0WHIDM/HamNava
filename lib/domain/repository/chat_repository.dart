import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';

abstract class IChatRepository {
  // ==================== Chats ====================

  Future<Either<ApiException, List<ConversationEntity>>> getAllChats();

  // داخل IChatRepository
  Future<Either<ApiException, ConversationEntity>> getChatById(String chatId);


  Future<Either<ApiException, ConversationEntity>> createGroupChat({
    required String chatName,
    required List<String> participantIds,
  });

  Future<Either<ApiException, ConversationEntity>> createOrGetPrivateChat(
    String targetUserId,
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
    required String chatId,
    String? text,
    // File? attachment, //
  });

  Stream<MessageEntity> listenToMessages(String chatId);

  Future<Either<ApiException, void>> deleteMessage(String messageId);

  Future<Either<ApiException, MessageEntity>> editMessage({
    required String messageId,
    required String newText,
  });
}
