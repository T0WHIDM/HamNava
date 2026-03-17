import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exeption/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';
import 'package:flutter_chat_room_app/domain/repository/chat_reposiroty.dart';

class GetMessageUseCase {
  final IChatRepository repository;
  GetMessageUseCase(this.repository);

  Future<Either<ApiExeption, List<MessageEntity>>> call(String chatId) {
    return repository.getMessages(chatId);
  }
}
