import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
import 'package:flutter_chat_room_app/domain/repository/chat_repository.dart';

class AddFriendToGroupUseCase {
  final IChatRepository repository;

  AddFriendToGroupUseCase(this.repository);

  Future<Either<ApiException, ConversationEntity>> call(
    String userId,
    String chatId,
  ) {
    return repository.addFriendToGroup(userId, chatId);
  }
}
