import 'package:pocketbase/pocketbase.dart';

class UserDto {
  final String id;
  final String userName;
  final String? avatar;
  final String email;
  final String name;

  UserDto({
    required this.userName,
    required this.id,
    this.avatar,
    required this.name,
    required this.email,
  });

  factory UserDto.fromRecord(RecordModel record) => UserDto(
    id: record.id,
    userName: record.data['userName'] ?? '',
    avatar: record.data['avatar'],
    email: record.data['email'] ?? '',
    name: record.data['name'] ?? '',
  );
}







