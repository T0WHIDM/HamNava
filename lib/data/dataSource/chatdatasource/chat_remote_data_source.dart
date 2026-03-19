import 'package:flutter_chat_room_app/data/dataSource/chatdatasource/chat_data_source.dart';
import 'package:flutter_chat_room_app/data/dtos/conversation_dto.dart';
import 'package:flutter_chat_room_app/data/dtos/message_dto.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';
import 'package:pocketbase/pocketbase.dart';

class ChatRemoteDataSource extends IChatDataSource {
  final PocketBase pb;
  ChatRemoteDataSource(this.pb);

  @override
  Future<ConversationDto> createGroupChat(String chatName, String chatId) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteChat(String chatId) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteMessage(String messageId) {
    throw UnimplementedError();
  }

  @override
  Future<MessageDto> editMessage({
    required String messageId,
    required String newText,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<ConversationDto>> getAllChats() {
    throw UnimplementedError();
  }

  @override
  Future<List<MessageDto>> getMessages(String chatId, {int page = 1}) {
    throw UnimplementedError();
  }

  @override
  Stream<MessageDto> listenToMessages(String chatId) {
    throw UnimplementedError();
  }

  @override
  Future<List<ConversationDto>> searchChat(String chatId) {
    throw UnimplementedError();
  }

  @override
  Future<List<MessageDto>> searchMessage(String chatId, String text) {
    throw UnimplementedError();
  }

  @override
  Future<MessageDto> sendMessage({
    required String text,
    required String chatId,
  }) {
    throw UnimplementedError();
  }
}
