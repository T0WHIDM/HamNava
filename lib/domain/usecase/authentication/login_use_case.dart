import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exeption/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/repository/authentication_repository.dart';

class LoginUseCase {
  final IAuthenticationReopsitory reopsitory;

  LoginUseCase(this.reopsitory);

  Future<Either<ApiExeption, void>> call(String userName, String password) {
    return reopsitory.login(userName, password);
  }
}
