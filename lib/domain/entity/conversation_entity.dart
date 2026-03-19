import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';

class ConversationEntity {
  final String id;
  final String name;
  final bool isGroup;
  final List<UserEntity> admin;
  final List<UserEntity> participants;

  ConversationEntity({
    required this.id,
    required this.name,
    required this.isGroup,
    required this.admin,
    required this.participants,
  });
}
