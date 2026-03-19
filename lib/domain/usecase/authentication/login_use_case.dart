import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/repository/authentication_repository.dart';

class LoginUseCase {
  final IAuthenticationRepository repository;

  LoginUseCase(this.repository);

  Future<Either<ApiException, void>> call(String userName, String password) {
    return repository.login(userName, password);
  }
}
