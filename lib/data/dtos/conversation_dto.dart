import 'package:flutter_chat_room_app/data/dtos/user_dto.dart';
import 'package:pocketbase/pocketbase.dart';

class ConversationDto {
  final String id;
  final String name;
  final bool isGroup;
  final String? admin;
  final List<UserDto> participants;

  ConversationDto({
    required this.id,
    required this.name,
    required this.isGroup,
    this.admin,
    required this.participants,
  });

  factory ConversationDto.fromRecord(RecordModel record) {
    final expandedUsers = record.get<List<RecordModel>>('expand.participants');

    return ConversationDto(
      id: record.id,
      name: record.getStringValue('name'),
      isGroup: record.getBoolValue('is_group'),
      admin: record.getStringValue('admin'),
      participants: expandedUsers
          .map((userRecord) => UserDto.fromRecord(userRecord))
          .toList(),
    );
  }
}
