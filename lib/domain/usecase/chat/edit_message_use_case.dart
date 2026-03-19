import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';
import 'package:flutter_chat_room_app/domain/repository/chat_repository.dart';

class EditMessageUseCase {
  final IChatRepository repository;

  EditMessageUseCase(this.repository);

  Future<Either<ApiException, MessageEntity>> call(
    String messageId,
    String newText,
  ) {
    return repository.editMessage(messageId: messageId, newText: newText);
  }
}
