import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';

abstract class ChatState {}

class ChatInitialState extends ChatState {}

class ChatLoadingState extends ChatState {}

class ChatInitializedResultState extends ChatState {
  final Either<ApiException, ConversationEntity> result;
  ChatInitializedResultState(this.result);
}

class ChatMessagesResultState extends ChatState {
  final Either<ApiException, List<MessageEntity>> result;
  ChatMessagesResultState(this.result);
}

class ChatMessageSentResultState extends ChatState {
  final Either<ApiException, MessageEntity> result;
  ChatMessageSentResultState(this.result);
}
