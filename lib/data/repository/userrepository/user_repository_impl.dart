import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/data/dataSource/userdatasource/user_data_source.dart';
import 'package:flutter_chat_room_app/data/mapper/user_mapper.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';
import 'package:flutter_chat_room_app/domain/repository/user_repository.dart';

class UserRepositoryImpl extends IUserRepository {
  final IUserDataSource dataSource;

  UserRepositoryImpl(this.dataSource);

  @override
  Future<Either<ApiException, UserEntity>> viewProfile(
    String userIdOrUsername,
  ) async {
    try {
      final userDto = await dataSource.viewProfile(userIdOrUsername);

      final userEntity = UserMapper.toDomain(userDto);

      return Right(userEntity);
    } catch (e) {
      return Left(ApiException('خطا در دریافت اطلاعات کاربر: '));
    }
  }

  @override
  Future<Either<ApiException, List<UserEntity>>> searchUser(
    String query,
  ) async {
    try {
      final userDtos = await dataSource.searchUser(query);

      final userEntities = UserMapper.toDomainList(userDtos);
      return Right(userEntities);
    } catch (e) {
      return Left(ApiException('خطا در جستجوی کاربر:'));
    }
  }

  @override
  Future<Either<ApiException, void>> updateProfile({
    required String userId,
    required String name,
    required String email,
    required String userName,
  }) async {
    try {
      await dataSource.updateProfile(
        userId: userId,
        name: name,
        email: email,
        userName: userName,
      );

      return const Right(null);
    } catch (e) {
      return Left(ApiException('خطا در بروزرسانی پروفایل: '));
    }
  }
}
