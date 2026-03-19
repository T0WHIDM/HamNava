import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';
import 'package:flutter_chat_room_app/domain/repository/user_repository.dart';

class SearchUserUseCase {
  final IUserRepository repository;

  SearchUserUseCase(this.repository);

  Future<Either<ApiException, List<UserEntity>>> call(String userName) {
    return repository.searchUser(userName);
  }
}
