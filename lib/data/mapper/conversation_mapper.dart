import 'package:flutter_chat_room_app/data/dtos/conversation_dto.dart';
import 'package:flutter_chat_room_app/data/mapper/user_mapper.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';

class ConversationMapper {
  static ConversationEntity toDomain(ConversationDto dto) {
    return ConversationEntity(
      id: dto.id,
      name: dto.name.isEmpty ? null : dto.name,
      isGroup: dto.isGroup,
      admin: dto.admin.map((userDto) => UserMapper.toDomain(userDto)).toList(),
      participants: dto.participants
          .map((userDto) => UserMapper.toDomain(userDto))
          .toList(),
    );
  }

  static List<ConversationEntity> toDomainList(
    List<ConversationDto> conversationEntityDtoList,
  ) {
    return conversationEntityDtoList
        .map((conversationEntityDto) => toDomain(conversationEntityDto))
        .toList();
  }
}
