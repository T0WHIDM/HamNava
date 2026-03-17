import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exeption/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';

abstract class IChatRepository {
  Future<Either<ApiExeption, List<ConversationEntity>>> getAllChat();

  Future<Either<ApiExeption, List<MessageEntity>>> getMessages(String chatId);

  Future<Either<ApiExeption, void>> sendMessage({
    required String text,
    required String chatId,
  });

  Stream<MessageEntity> listenToMessage(String chatId);

}
