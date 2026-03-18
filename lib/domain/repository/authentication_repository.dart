import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exeption/api_exeption.dart';

abstract class IAuthenticationRepository {
  Future<Either<ApiExeption, void>> login(String userName, String password);

  Future<Either<ApiExeption, void>> register(
    String name,
    String userName,
    String email,
    String password,
    String passwordConfirm,
  );

  Future<Either<ApiExeption, void>> logOut();

}
