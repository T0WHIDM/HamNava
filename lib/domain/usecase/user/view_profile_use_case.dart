import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';
import 'package:flutter_chat_room_app/domain/repository/user_repository.dart';

class ViewProfileUseCase {
  final IUserRepository userRepository;
  ViewProfileUseCase(this.userRepository);

  Future<Either<ApiException, UserEntity>> call(
    String userIdOrUsername,
  ) {
    return userRepository.viewProfile(userIdOrUsername);
  }
}
