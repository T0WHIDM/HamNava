import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exeption/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/repository/chat_reposiroty.dart';

class SendMessageUseCase {
  final IChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<ApiExeption, void>> call({
    required String text,
    required String chatId,
  }) {
    return repository.sendMessage(text: text, chatId: chatId);
  }
}
