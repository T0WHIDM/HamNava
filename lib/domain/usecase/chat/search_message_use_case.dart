import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';
import 'package:flutter_chat_room_app/domain/repository/chat_repository.dart';

class SearchMessageUseCase {
  final IChatRepository repository;

  SearchMessageUseCase(this.repository);

  Future<Either<ApiException, List<MessageEntity>>> call(
    String chatId,
    String text,
  ) {
    return repository.searchMessage(chatId, text);
  }
}
