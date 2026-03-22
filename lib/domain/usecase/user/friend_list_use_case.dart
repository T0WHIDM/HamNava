import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';
import 'package:flutter_chat_room_app/domain/repository/user_repository.dart';

class FriendListUseCase {
  final IUserRepository repository;
  FriendListUseCase(this.repository);

  Future<Either<ApiException, List<UserEntity>>> call(String userId) {
    return repository.friendsList(userId);
  }
}
