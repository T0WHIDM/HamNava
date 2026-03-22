import 'package:flutter_chat_room_app/data/dtos/user_dto.dart';

abstract class IUserDataSource {

  Future<List<UserDto>> searchUser(String query);

  Future<void> updateProfile({
    required String userId,
    required String name,
    required String email,
    required String userName,
    // File? avatar,
  });

  Future<void> addFriend(String userId);

  Future<List<UserDto>> friendsList(String userId);
}
