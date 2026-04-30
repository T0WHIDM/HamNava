import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';

abstract class IAuthenticationRepository {
  //login
  Future<Either<ApiException, void>> login(String userName, String password);

  //register
  Future<Either<ApiException, void>> register(
    String name,
    String userName,
    String email,
    String password,
    String passwordConfirm,
    // File? avatarFile,
  );

  //log out
  Future<Either<ApiException, void>> logOut();
}
