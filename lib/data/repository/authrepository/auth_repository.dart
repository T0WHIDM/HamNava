import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/data/dataSource/authdatasource/auth_data_source.dart';
import 'package:flutter_chat_room_app/domain/repository/authentication_repository.dart';

class AuthRepositoryImpl implements IAuthenticationRepository {
  final IAuthDataSource dataSource;
  AuthRepositoryImpl(this.dataSource);

  //logout
  @override
  Future<Either<ApiException, void>> logOut() async {
    try {
      await dataSource.logOut();
      return const Right(null);
    } catch (e) {
      return Left(ApiException('خطا در خروج از حساب'));
    }
  }

  //login
  @override
  Future<Either<ApiException, void>> login(
    String userName,
    String password,
  ) async {
    try {
      await dataSource.login(userName, password);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ApiException('خطای غیرمنتظره در ورود'));
    }
  }

  //register
  @override
  Future<Either<ApiException, void>> register(
    String name,
    String userName,
    String email,
    String password,
    String passwordConfirm,
    // File? avatarFile,
  ) async {
    try {
      await dataSource.register(
        name,
        userName,
        email,
        password,
        passwordConfirm,
        // avatarFile,
      );
      return const Right(null);
    } on ApiException catch (e) {
      return Left(e);
    }
  }
}
