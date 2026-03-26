import 'package:flutter_chat_room_app/data/dtos/user_dto.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';

class UserMapper {
  static UserEntity toDomain(UserDto userDto) {
    return UserEntity(
      userName: userDto.userName,
      id: userDto.id,
      email: userDto.email,
      name: userDto.name,
      avatar: userDto.avatar,
      friends: UserMapper.toDomainList(userDto.friends),
    );
  }

  static List<UserEntity> toDomainList(List<UserDto> userDtos) {
    return userDtos.map((userEntityDto) => toDomain(userEntityDto)).toList();
  }
}
