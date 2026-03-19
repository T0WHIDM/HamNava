// فایل: message_mapper.dart
import 'package:flutter_chat_room_app/data/dtos/message_dto.dart';
import 'package:flutter_chat_room_app/data/mapper/user_mapper.dart';
import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';

class MessageMapper {
  static MessageEntity toDomain(MessageDto messageDto) {
    return MessageEntity(
      id: messageDto.id,
      text: messageDto.text,
      chatId: messageDto.chatId,
      file: messageDto.attachment,
      created: messageDto.created,
      sender: messageDto.sender != null
          ? UserMapper.toDomain(messageDto.sender!)
          : UserEntity(
              id: '',
              userName: 'unknown_user',
              email: '',
              name: 'Deleted Account',
            ),
    );
  }

  static List<MessageEntity> toDomainList(List<MessageDto> messageDto) {
    return messageDto
        .map((messageEntityDto) => toDomain(messageEntityDto))
        .toList();
  }
}
