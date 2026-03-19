import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/repository/authentication_repository.dart';

class RegisterUseCase {
  final IAuthenticationRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<ApiException, void>> call(
    String name,
    String userName,
    String email,
    String password,
    String passwordConfirm,
  ) {
    return repository.register(
      name,
      userName,
      email,
      password,
      passwordConfirm,
    );
  }
}
