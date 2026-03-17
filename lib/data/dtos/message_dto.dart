import 'package:flutter_chat_room_app/data/dtos/user_dto.dart';
import 'package:pocketbase/pocketbase.dart';

class MessageDto {
  final String id;
  final String text;
  final UserDto? sender;
  final String chatId;
  final String? attachment;
  final DateTime created;

  MessageDto({
    required this.id,
    required this.text,
    required this.sender,
    required this.chatId,
    this.attachment,
    required this.created,
  });

  factory MessageDto.fromRecord(RecordModel record) {
    final expandedList = record.get<List<RecordModel>>('expand.sender_id');
    final expandedUser = expandedList.isNotEmpty ? expandedList.first : null;

    return MessageDto(
      id: record.id,
      text: record.getStringValue('text'),
      chatId: record.getStringValue('chat_id'),
      attachment: record.getStringValue('attachment'),
      created: record.get<DateTime>('created'),
      sender: expandedUser != null
          ? UserDto.fromRecord(expandedUser)
          : null,
    );
  }
}
