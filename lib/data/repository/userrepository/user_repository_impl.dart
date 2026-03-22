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

  @override
  Future<Either<ApiException, void>> addFriend(String userId) async {
    try {
      await dataSource.addFriend(userId);
      return right(null);
    } catch (e) {
      return left(ApiException('خطایی در افزودن دوست به وجود امده است'));
    }
  }

  @override
  Future<Either<ApiException, List<UserEntity>>> friendsList(
    String userId,
  ) async {
    try {
      final friendsListDto = await dataSource.friendsList(userId);

      final userEntities = UserMapper.toDomainList(friendsListDto);
      return right(userEntities);
    } catch (e) {
      throw ApiException('خطا در نمایش لیست دوستان شما');
    }
  }
}
