import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/repository/authentication_repository.dart';

class LogOutUseCase {
  final IAuthenticationRepository repository;
  LogOutUseCase(this.repository);
  
  Future<Either<ApiException, void>> call() => repository.logOut();
}
