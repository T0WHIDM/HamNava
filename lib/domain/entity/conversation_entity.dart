import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';

class ConversationEntity {
  final String id;
  final String name;
  final bool isGroup; 
  final String? admin;
  final List<UserEntity> participants;

  ConversationEntity({
    required this.id,
    required this.name,
    required this.isGroup,
     this.admin,
    required this.participants,
  });
}
