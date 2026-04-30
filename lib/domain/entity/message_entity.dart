import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';

class MessageEntity {
  final String id;
  final String? text;
  final UserEntity sender;
  final String chatId;
  final String? attachment;
  final DateTime created;
  // final List<UserEntity> readBy;
  // final String type;
  // final bool isDeleted;
  final MessageEntity? replyTo; 

  MessageEntity({
    required this.id,
    required this.text,
    required this.sender,
    required this.chatId,
    this.attachment,
    required this.created,
    // required this.readBy,
    // required this.type,
    // required this.isDeleted,
    this.replyTo,
  });
}
