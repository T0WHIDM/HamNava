import 'package:flutter_chat_room_app/data/dtos/user_dto.dart';
import 'package:pocketbase/pocketbase.dart';

class ConversationDto {
  final String id;
  final String name;
  final bool isGroup;
  final List<UserDto> admin;
  final List<UserDto> participants;

  ConversationDto({
    required this.id,
    required this.name,
    required this.isGroup,
    required this.admin,
    required this.participants,
  });

  factory ConversationDto.fromRecord(RecordModel record) {
    final expandedUsers = record.get<List<RecordModel>>('expand.participants');
    final expandedAdmin = record.get<List<RecordModel>>('expand.admin');

    return ConversationDto(
      id: record.id,
      name: record.getStringValue('name'),
      isGroup: record.getBoolValue('is_group'),
      admin: expandedAdmin.map((e) => UserDto.fromRecord(e)).toList(),
      participants: expandedUsers
          .map((userRecord) => UserDto.fromRecord(userRecord))
          .toList(),
    );
  }
}
