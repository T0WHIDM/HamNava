import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/repository/chat_repository.dart';

class DeleteChatUseCase {
  final IChatRepository repository;

  DeleteChatUseCase(this.repository);

  Future<Either<ApiException, void>> call(String chatId) {
    return repository.deleteChat(chatId);
  }
}
