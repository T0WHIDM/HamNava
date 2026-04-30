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
  // final List<UserDto> readBy;
  // final String type;
  // final bool isDeleted;
  final MessageDto? replyTo;

  MessageDto({
    required this.id,
    required this.text,
    required this.senderId,
    required this.sender,
    required this.chatId,
    this.attachment,
    required this.created,
    // required this.readBy,
    // required this.type,
    // required this.isDeleted,
    this.replyTo,
  });

  factory MessageDto.fromRecord(RecordModel record) {
    MessageDto? replyData;
    RecordModel? senderRecord;
    // List<RecordModel> readByList = [];

    final expand = record.expand;

    if (expand.containsKey('reply_to')) {
      final replyObj = expand['reply_to'];
      if (replyObj != null && replyObj.isNotEmpty) {
        replyData = MessageDto.fromRecord(replyObj.first);
      }
    }

    if (expand.containsKey('sender_id')) {
      final senderObj = expand['sender_id'];
      if (senderObj != null && senderObj.isNotEmpty) {
        senderRecord = senderObj.first;
      }
    }

    // if (expand.containsKey('read_by')) {
    //   final readByObj = expand['read_by'];
    //   if (readByObj != null) {
    //     readByList = List<RecordModel>.from(readByObj);
    //   }
    // }

    return MessageDto(
      id: record.id,
      text: record.getStringValue('text'),
      chatId: record.getStringValue('chat_id'),
      attachment: record.getStringValue('file'),
      created: DateTime.parse(record.getStringValue('created')),
      sender: senderRecord != null ? UserDto.fromRecord(senderRecord) : null,
      senderId: record.getStringValue('sender_id'),
      // readBy: readByList.map((e) => UserDto.fromRecord(e)).toList(),
      // type: record.getStringValue('type'),
      // isDeleted: record.getBoolValue('is_deleted'),
      replyTo: replyData,
    );
  }
}
