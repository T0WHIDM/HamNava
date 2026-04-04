import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';
import 'package:flutter_chat_room_app/domain/repository/chat_repository.dart';

class SendMessageUseCase {
  final IChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<ApiException, MessageEntity>> call({
    required String chatId,
    String? text,
    String? replyId,
    File? attachment,
  }) {
    return repository.sendMessage(
      text: text,
      chatId: chatId,
      replyId: replyId,
      attachment: attachment,
    );
  }
}
