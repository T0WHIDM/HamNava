import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';
import 'package:flutter_chat_room_app/domain/repository/chat_repository.dart';

class GetMessageUseCase {
  final IChatRepository repository;

  GetMessageUseCase(this.repository);

  Future<Either<ApiException, List<MessageEntity>>> call(
    String chatId, {
    int page = 1,
  }) {
    return repository.getMessages(chatId, page: page);
  }
}
