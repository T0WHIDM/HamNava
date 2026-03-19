// import 'package:dartz/dartz.dart';
// import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
// import 'package:flutter_chat_room_app/data/dataSource/chatdatasource/chat_data_source.dart';
// import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
// import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';
// import 'package:flutter_chat_room_app/domain/repository/chat_repository.dart';

// class ChatRepositoryImpl extends IChatRepository {
//   final IChatDataSource dataSource;
//   ChatRepositoryImpl(this.dataSource);

//   @override
//   Future<Either<ApiException, ConversationEntity>> createGroupChat(
//     String chatName,
//     String chatId,
//   ) {
//     throw UnimplementedError();
//   }

//   @override
//   Future<Either<ApiException, void>> deleteChat(String chatId) {
//     throw UnimplementedError();
//   }

//   @override
//   Future<Either<ApiException, void>> deleteMessage(String messageId) {
//     throw UnimplementedError();
//   }

//   @override
//   Future<Either<ApiException, MessageEntity>> editMessage({
//     required String messageId,
//     required String newText,
//   }) {
//     throw UnimplementedError();
//   }

//   @override
//   Future<Either<ApiException, List<ConversationEntity>>> getAllChats() {
//     throw UnimplementedError();
//   }

//   @override
//   Future<Either<ApiException, List<MessageEntity>>> getMessages(
//     String chatId, {
//     int page = 1,
//   }) {
//     throw UnimplementedError();
//   }

//   @override
//   Stream<MessageEntity> listenToMessages(String chatId) {
//     throw UnimplementedError();
//   }

//   @override
//   Future<Either<ApiException, List<ConversationEntity>>> getChatById(
//     String chatId,
//   ) {
//     throw UnimplementedError();
//   }

//   @override
//   Future<Either<ApiException, List<MessageEntity>>> searchMessage(
//     String chatId,
//     String text,
//   ) {
//     throw UnimplementedError();
//   }

//   @override
//   Future<Either<ApiException, MessageEntity>> sendMessage({
//     required String text,
//     required String chatId,
//   }) {
//     throw UnimplementedError();
//   }
  
//   @override
//   Future<Either<ApiException, ConversationEntity>> createOrGetPrivateChat(String targetUserId) {
//     // TODO: implement createOrGetPrivateChat
//     throw UnimplementedError();
//   }
// }
