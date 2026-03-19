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
    List<RecordModel> safeGetExpand(String key) {
      try {
        return record.get<List<RecordModel>>('expand.$key');
      } catch (_) {
        return [];
      }
    }

    final participantsList = safeGetExpand('participants');
    final adminList = safeGetExpand('admin');

    return ConversationDto(
      id: record.id,
      name: record.getStringValue('name'),
      isGroup: record.getBoolValue('is_group'),
      admin: adminList.map((e) => UserDto.fromRecord(e)).toList(),
      participants: participantsList.map((e) => UserDto.fromRecord(e)).toList(),
    );
  }
}
