import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exeption/api_exeption.dart';
import 'package:flutter_chat_room_app/data/dataSource/chatdatasource/chat_data_source.dart';
import 'package:flutter_chat_room_app/data/mapper/conversation_mapper.dart';
import 'package:flutter_chat_room_app/data/mapper/message_mapper.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';
import 'package:flutter_chat_room_app/domain/repository/chat_reposiroty.dart';

class ChatRepositoryImpl implements IChatRepository {
  final IChatDataSource dataSource;

  ChatRepositoryImpl(this.dataSource);

  @override
  Future<Either<ApiExeption, List<ConversationEntity>>> getAllChat() async {
    try {
      final dtos = await dataSource.getAllChat();

      final entities = ConversationMapper.toDomainList(dtos);

      return Right(entities);
    } on ApiExeption catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ApiExeption('خطای نامشخص در دریافت چت‌ها: $e'));
    }
  }

  @override
  Future<Either<ApiExeption, List<MessageEntity>>> getMessages(
    String chatId,
  ) async {
    try {
      final dtos = await dataSource.getMessages(chatId);
      final entities = MessageMapper.toDomainList(dtos);
      return Right(entities);
    } on ApiExeption catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ApiExeption('خطای نامشخص در دریافت پیام‌ها: $e'));
    }
  }

  @override
  Future<Either<ApiExeption, void>> sendMessage({
    required String text,
    required String chatId,
  }) async {
    try {
      await dataSource.sendMessage(text: text, chatId: chatId);
      return const Right(null);
    } on ApiExeption catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ApiExeption('خطای نامشخص در ارسال پیام: $e'));
    }
  }

  @override
  Stream<MessageEntity> listenToMessage(String chatId) {
    return dataSource
        .listenToMessage(chatId)
        .map((messageDto) => MessageMapper.toDomain(messageDto));
  }
}
