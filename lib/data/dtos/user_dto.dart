import 'package:pocketbase/pocketbase.dart';

class UserDto {
  final String id;
  final String userName;
  // final String? avatar;
  final String email;
  final String name;

  UserDto({
    required this.userName,
    required this.id,
    // this.avatar,
    required this.name,
    required this.email,
  });

  factory UserDto.fromRecord(RecordModel record) => UserDto(
    id: record.id,
    userName: record.getStringValue('userName'),
    // avatar: record.getStringValue('avatar'),
    email: record.getStringValue('email'),
    name: record.getStringValue('name'),
  );
}
