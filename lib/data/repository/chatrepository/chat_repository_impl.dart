import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/data/dataSource/chatdatasource/chat_data_source.dart';
import 'package:flutter_chat_room_app/data/mapper/conversation_mapper.dart';
import 'package:flutter_chat_room_app/data/mapper/message_mapper.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';
import 'package:flutter_chat_room_app/domain/repository/chat_repository.dart';

class ChatRepositoryImpl extends IChatRepository {
  final IChatDatasource dataSource;

  ChatRepositoryImpl(this.dataSource);

  @override
  Future<Either<ApiException, ConversationEntity>> createOrGetGroupChat({
    required String chatName,
    required List<UserEntity> participantIds,
  }) async {
    try {
      final List<String> idsList = participantIds
          .map((user) => user.id)
          .toList();

      final dto = await dataSource.createOrGetGroupChat(
        chatName: chatName,
        participantIds: idsList,
      );
      return Right(ConversationMapper.toDomain(dto));
    } catch (e) {
      return Left(ApiException('خطا در ایجاد گروه: '));
    }
  }

  @override
  Future<Either<ApiException, ConversationEntity>> createOrGetPrivateChat(
    String targetUserId,
  ) async {
    try {
      final dto = await dataSource.createOrGetPrivateChat(targetUserId);
      return Right(ConversationMapper.toDomain(dto));
    } catch (e) {
      return Left(ApiException('خطا در شروع گفتگو'));
    }
  }

  @override
  Future<Either<ApiException, void>> deleteChat(String chatId) async {
    try {
      await dataSource.deleteChat(chatId);
      return const Right(null);
    } catch (e) {
      return Left(ApiException('خطا در حذف چت: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ApiException, void>> deleteMessage(
    String messageId,
    String chatId,
  ) async {
    try {
      await dataSource.deleteMessage(messageId, chatId);
      return const Right(null);
    } catch (e) {
      return Left(ApiException('خطا در حذف پیام: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ApiException, MessageEntity>> editMessage({
    required String messageId,
    required String newText,
  }) async {
    try {
      final dto = await dataSource.editMessage(
        messageId: messageId,
        newText: newText,
      );
      return Right(MessageMapper.toDomain(dto));
    } catch (e) {
      return Left(ApiException('خطا در ویرایش پیام: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ApiException, List<ConversationEntity>>> getAllChats() async {
    try {
      final dtos = await dataSource.getAllChats();
      final entities = ConversationMapper.toDomainList(dtos);
      return Right(entities);
    } catch (e) {
      return Left(ApiException('خطا در دریافت لیست چت‌ها: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ApiException, List<MessageEntity>>> getMessages(
    String chatId, {
    int page = 1,
  }) async {
    try {
      final dtos = await dataSource.getMessages(chatId, page: page);
      final entities = MessageMapper.toDomainList(dtos);
      return Right(entities);
    } catch (e) {
      return Left(ApiException('خطا در دریافت پیام‌ها'));
    }
  }

  @override
  Stream<({String action, MessageEntity message})> listenToMessages(
    String chatId,
  ) {
    return dataSource
        .listenToMessages(chatId)
        .map(
          (data) => (
            action: data.action,
            message: MessageMapper.toDomain(data.message),
          ),
        );
  }

  @override
  Future<Either<ApiException, MessageEntity>> sendMessage({
    required String chatId,
    String? text,
    String? replyId,
    File? attachment 
  }) async {
    try {
      final dto = await dataSource.sendMessage(
        chatId: chatId,
        text: text,
        replyId: replyId,
        attachment: attachment
      );

      return Right(MessageMapper.toDomain(dto));
    } catch (e) {
      return Left(ApiException('خطا در ارسال پیام'));
    }
  }

  @override
  Future<Either<ApiException, ConversationEntity>> addFriendToGroup(
    String userId,
    String chatId,
  ) async {
    try {
      final dto = await dataSource.addFriendToGroup(userId, chatId);
      return right(ConversationMapper.toDomain(dto));
    } catch (e) {
      return left(ApiException('خطا در اضافه کردن عضو به گروه'));
    }
  }

  @override
  Future<Either<ApiException, void>> leaveFromGroup(
    String userId,
    String chatId,
  ) async {
    try {
      await dataSource.leaveFromGroup(userId, chatId);
      return right(null);
    } catch (e) {
      return left(ApiException('خطا در ترک کردن  گروه'));
    }
  }
}
