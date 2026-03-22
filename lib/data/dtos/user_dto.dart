import 'package:pocketbase/pocketbase.dart';

class UserDto {
  final String id;
  final String userName;
  // final String? avatar;
  final String email;
  final String name;
  final List<UserDto> friends;

  UserDto({
    required this.userName,
    required this.id,
    // this.avatar,
    required this.name,
    required this.email,
    required this.friends,
  });

  factory UserDto.fromRecord(RecordModel record) {
    final friendsList = record.get<List<RecordModel>>('expand.friend');

    return UserDto(
      id: record.id,
      userName: record.getStringValue('userName'),
      // avatar: record.getStringValue('avatar'),
      email: record.getStringValue('email'),
      name: record.getStringValue('name'),
      friends: friendsList.map((e) => UserDto.fromRecord(e)).toList(),
    );
  }
}
