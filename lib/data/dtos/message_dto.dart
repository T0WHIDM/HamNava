import 'package:flutter_chat_room_app/data/dtos/user_dto.dart';
import 'package:pocketbase/pocketbase.dart';

class MessageDto {
  final String id;
  final String text;
  final String senderId;
  final UserDto? sender;
  final String chatId;
  final String? attachment;
  final DateTime created;
  final List<UserDto> readBy;
  final String type;
  final bool isDeleted;
  final String replyToId;

  MessageDto({
    required this.id,
    required this.text,
    required this.senderId,
    required this.sender,
    required this.chatId,
    this.attachment,
    required this.created,
    required this.readBy,
    required this.type,
    required this.isDeleted,
    required this.replyToId,
  });

  factory MessageDto.fromRecord(RecordModel record) {
    RecordModel? senderRecord;

    try {
      final senders = record.get<List<RecordModel>>('expand.sender_id');
      if (senders.isNotEmpty) {
        senderRecord = senders.first;
      }
    } catch (_) {
      senderRecord = null;
    }

    List<RecordModel> readByList = [];
    try {
      readByList = record.get<List<RecordModel>>('expand.read_by');
    } catch (_) {
      readByList = [];
    }

    return MessageDto(
      id: record.id,
      text: record.getStringValue('text'),
      chatId: record.getStringValue('chat_id'),
      attachment: record.getStringValue('attachment'),
      created: DateTime.parse(record.getStringValue('created')),
      sender: senderRecord != null ? UserDto.fromRecord(senderRecord) : null,
      senderId: record.getStringValue('sender_id'),
      readBy: readByList.map((e) => UserDto.fromRecord(e)).toList(),
      type: record.getStringValue('type'),
      isDeleted: record.getBoolValue('is_deleted'),
      replyToId: record.getStringValue('reply_to'),
    );
  }
}
