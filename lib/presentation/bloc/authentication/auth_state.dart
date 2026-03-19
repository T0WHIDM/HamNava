import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final Either<ApiException, void> result;

  AuthSuccess(this.result);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
