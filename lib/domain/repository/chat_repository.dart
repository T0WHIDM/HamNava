import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';

abstract class IChatRepository {
  // ==================== Chats ====================

  Future<Either<ApiException, List<ConversationEntity>>> getAllChats();

  Future<Either<ApiException, ConversationEntity>> createOrGetGroupChat({
    required String chatName,
    required List<UserEntity> participantIds,
  });

  Future<Either<ApiException, ConversationEntity>> createOrGetPrivateChat(
    String targetUserId,
  );

  Future<Either<ApiException, void>> deleteChat(String chatId);

  Future<Either<ApiException, ConversationEntity>> addFriendToGroup(
    String userId,
    String chatId,
  );

  Future<Either<ApiException, void>> leaveFromGroup(
    String userId,
    String chatId,
  );

  // ==================== Messages ====================

  Future<Either<ApiException, List<MessageEntity>>> getMessages(
    String chatId, {
    int page = 1,
  });

  Future<Either<ApiException, MessageEntity>> sendMessage({
    required String chatId,
    String? text,
    String? replyId,
    File? attachment,
  });

  Stream<({String action, MessageEntity message})> listenToMessages(
    String chatId,
  );

  Future<Either<ApiException, void>> deleteMessage(
    String messageId,
    String chatId,
  );

  Future<Either<ApiException, MessageEntity>> editMessage({
    required String messageId,
    required String newText,
  });
}
