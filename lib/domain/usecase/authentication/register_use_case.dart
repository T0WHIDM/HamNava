import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exeption/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/repository/authentication_repository.dart';

class RegisterUseCase {
  final IAuthenticationReopsitory reopsitory;

  RegisterUseCase(this.reopsitory);

  Future<Either<ApiExeption, void>> call(
    String name,
    String userName,
    String email,
    String password,
    String passwordConfirm,
    String? avatar,
  ) {
    return reopsitory.register(
      name,
      userName,
      email,
      password,
      passwordConfirm,
      avatar,
    );
  }
}
