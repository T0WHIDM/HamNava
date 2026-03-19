import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';

class MessageEntity {
  final String id;
  final String? text;
  final UserEntity sender;
  final String chatId;
  final String? file;
  final DateTime created;

  MessageEntity({
    required this.id,
    required this.text,
    required this.sender,
    required this.chatId,
    this.file,
    required this.created,
  });
}
