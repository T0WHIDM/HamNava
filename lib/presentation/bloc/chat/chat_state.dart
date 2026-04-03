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

class ChatNewMessageRealTimeState extends ChatState {
  final MessageEntity result;

  ChatNewMessageRealTimeState(this.result);
}

class ChatMessageUpdatedRealtimeState extends ChatState {
  final MessageEntity message;
  ChatMessageUpdatedRealtimeState(this.message);
}

class ChatMessageDeletedRealtimeState extends ChatState {
  final String messageId;
  ChatMessageDeletedRealtimeState(this.messageId);
}

class DeleteMessageSuccessState extends ChatState {
  final Either<ApiException, void> result;

  DeleteMessageSuccessState(this.result);
}

class ChatListSUccessState extends ChatState {
  final Either<ApiException, List<ConversationEntity>> result;

  ChatListSUccessState(this.result);
}

class EditMessageSuccessState extends ChatState {
  final Either<ApiException, MessageEntity> result;

  EditMessageSuccessState(this.result);
}

class DeleteChatSuccessStete extends ChatState {
  final Either<ApiException, void> result;

  DeleteChatSuccessStete(this.result);
}

class CreateGroupSuccessState extends ChatState {
  final Either<ApiException, ConversationEntity> groupChat;
  CreateGroupSuccessState(this.groupChat);
}

class AddFriendToGroupSuccessState extends ChatState {
  final Either<ApiException, ConversationEntity> result;

  AddFriendToGroupSuccessState(this.result);
}

class LeaveFromGroupSuccessState extends ChatState {
  final Either<ApiException, void> result;

  LeaveFromGroupSuccessState(this.result);
}

class ChatLoadMoreResultState extends ChatState {
  final Either<ApiException, List<MessageEntity>> result;

  ChatLoadMoreResultState(this.result);
}
