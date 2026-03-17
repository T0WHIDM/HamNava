import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exeption/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
import 'package:flutter_chat_room_app/domain/repository/chat_reposiroty.dart';

class GetAllChatUseCase {
  final IChatRepository repository;
  GetAllChatUseCase(this.repository);

  Future<Either<ApiExeption, List<ConversationEntity>>> call() {
    return repository.getAllChat();
  }
}
