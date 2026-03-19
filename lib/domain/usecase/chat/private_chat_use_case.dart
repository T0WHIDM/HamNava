import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
import 'package:flutter_chat_room_app/domain/repository/chat_repository.dart';

class PrivateChatUseCase {
  final IChatRepository repository;

  PrivateChatUseCase(this.repository);

  Future<Either<ApiException, ConversationEntity>> call(String targetUserId) {
    return repository.createOrGetPrivateChat(targetUserId);
  }
}
