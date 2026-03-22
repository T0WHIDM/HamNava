import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';

abstract class IUserRepository {
  // ==================== User ====================

  Future<Either<ApiException, List<UserEntity>>> searchUser(String query);

  Future<Either<ApiException, void>> updateProfile({
    required String userId,
    required String name,
    required String email,
    required String userName,
    // File? avatar,
  });

  Future<Either<ApiException, void>> addFriend(String userId);

  Future<Either<ApiException, List<UserEntity>>> friendsList(String userId);
}
