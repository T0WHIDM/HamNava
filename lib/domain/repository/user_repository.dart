import 'dart:core';
import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';

abstract class IUserRepository {
  // ==================== User ====================

  Future<Either<ApiException, UserEntity>> viewProfile(String userIdOrUsername);

  Future<Either<ApiException, UserEntity>> searchUser(String userName);

  Future<Either<ApiException, void>> updateProfile({
    required String name,
    required String email,
    required String userName,
    // File? avatar,
  });
}
