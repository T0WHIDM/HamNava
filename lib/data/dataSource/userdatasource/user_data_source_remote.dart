import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/data/dataSource/userdatasource/user_data_source.dart';
import 'package:flutter_chat_room_app/data/dtos/user_dto.dart';
import 'package:pocketbase/pocketbase.dart';

class UserDataSourceRemote extends IUserDataSource {
  final PocketBase pb;
  UserDataSourceRemote(this.pb);

  @override
  Future<List<UserDto>> searchUser(String query) async {
    try {
      final myUserId = locator<PocketBase>().authStore.record?.id ?? '';

      final result = await pb
          .collection('users')
          .getList(
            page: 1,
            perPage: 30,
            filter: 'userName ~ "$query" && id != "$myUserId"',
          );

      return result.items.map((record) => UserDto.fromRecord(record)).toList();
    } catch (e) {
      throw Exception('خطا در جستجوی کاربر');
    }
  }

  @override
  Future<void> updateProfile({
    required String userId,
    required String name,
    required String email,
    required String userName,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'email': email,
        'userName': userName,
      };

      await pb.collection('users').update(userId, body: body);
    } catch (e) {
      throw Exception('خطا در اپدیت پروفایل');
    }
  }

  @override
  Future<void> addFriend(String userId) async {
    try {
      final myUserId = locator<PocketBase>().authStore.record?.id ?? '';
      // if (myUserId.isEmpty) throw ApiException('کاربر لاگین نیست');

      final currentUserRecord = await pb.collection('users').getOne(myUserId);

      List<String> myFriends = List<String>.from(
        currentUserRecord.data['friend'] ?? [],
      );

      if (!myFriends.contains(userId)) {
        myFriends.add(userId);

        await pb
            .collection('users')
            .update(myUserId, body: {'friend': myFriends});
      }
    } catch (e) {
      throw ApiException('خطا در اضافه کردن دوست');
    }
  }

  @override
  Future<List<UserDto>> friendsList(String userId) async {
    try {
      final record = await pb
          .collection('users')
          .getOne(userId, expand: 'friend');

      final List<RecordModel> friendsRecord = record.get<List<RecordModel>>(
        'expand.friend',
      );

      return friendsRecord.map((friendRecord) {
        return UserDto.fromRecord(friendRecord);
      }).toList();
    } catch (e) {
      throw ApiException('خطایی در نمایش لیست دوستان شما به وجود امده است');
    }
  }

  @override
  Future<UserDto> getProfileInfo(String currentUserId) async {
    try {
      final record = await pb.collection('users').getOne(currentUserId);
      return UserDto.fromRecord(record);
    } catch (e) {
      throw ApiException('خطا در دریافت اطلاعات کاربر');
    }
  }
}
