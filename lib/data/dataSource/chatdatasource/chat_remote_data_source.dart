import 'dart:async';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/data/dataSource/chatdatasource/chat_data_source.dart';
import 'package:flutter_chat_room_app/data/dtos/conversation_dto.dart';
import 'package:flutter_chat_room_app/data/dtos/message_dto.dart';
import 'package:pocketbase/pocketbase.dart';

class ChatRemoteDataSourceImpl implements IChatDatasource {
  final PocketBase pb;
  ChatRemoteDataSourceImpl(this.pb);

  @override
  Future<ConversationDto> createGroupChat({
    required String chatName,
    required List<String> participantIds,
  }) async {
    try {
      final body = <String, dynamic>{
        "name": chatName,
        "is_group": true,
        "participants": participantIds,
      };

      final record = await pb
          .collection('chat')
          .create(body: body, expand: 'participants');

      return ConversationDto.fromRecord(record);
    } catch (e) {
      throw ApiException('مشکلی در ساخت گروه پیش آمده است');
    }
  }

  @override
  Future<ConversationDto> createOrGetPrivateChat(String targetUserId) async {
    try {
      final currentUserId = pb.authStore.record?.id;

      final filter =
          'is_group = false && participants ~ "$currentUserId" && participants ~ "$targetUserId"';

      final existingChats = await pb
          .collection('chat')
          .getList(filter: filter, expand: 'participants');

      if (existingChats.items.isNotEmpty) {
        return ConversationDto.fromRecord(existingChats.items.first);
      }

      final body = <String, dynamic>{
        "name": "",
        "is_group": false,
        "participants": [currentUserId, targetUserId],
      };

      final record = await pb
          .collection('chat')
          .create(body: body, expand: 'participants');
      return ConversationDto.fromRecord(record);
    } catch (e) {
      throw ApiException('مشکلی در ایجاد گفتگو با کاربر پیش آمده است');
    }
  }

  @override
  Future<void> deleteChat(String chatId) async {
    try {
      await pb.collection('chat').delete(chatId);
    } catch (e) {
      throw ApiException('مشکلی در حذف چت به وجود آمده است');
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      await pb.collection('messages').delete(messageId);
    } catch (e) {
      throw ApiException('مشکلی در حذف پیام به وجود آمده است');
    }
  }

  @override
  Future<MessageDto> editMessage({
    required String messageId,
    required String newText,
  }) async {
    try {
      final record = await pb
          .collection('messages')
          .update(messageId, body: {'text': newText});
      return MessageDto.fromRecord(record);
    } catch (e) {
      throw ApiException('خطا در ویرایش پیام');
    }
  }

  @override
  Future<List<ConversationDto>> getAllChats() async {
    try {
      final resultList = await pb
          .collection('chat')
          .getList(
            page: 1,
            perPage: 50,
            sort: '-updated',
            expand: 'participants,last_message',
          );

      return resultList.items
          .map((record) => ConversationDto.fromRecord(record))
          .toList();
    } catch (e) {
      throw ApiException("مشکلی در دریافت چت‌ها به وجود آمده است");
    }
  }

  @override
  Future<ConversationDto> getChatById(String chatId) async {
    try {
      final record = await pb
          .collection('chat')
          .getOne(chatId, expand: 'participants');
      return ConversationDto.fromRecord(record);
    } catch (e) {
      throw ApiException("چت مورد نظر یافت نشد");
    }
  }

  @override
  Future<List<MessageDto>> getMessages(String chatId, {int page = 1}) async {
    try {
      final result = await pb
          .collection('messages')
          .getList(
            page: page,
            perPage: 40,
            filter: 'chat_id = "$chatId"',
            sort: '-created',
            expand: 'sender_id',
          );

      return result.items
          .map((record) => MessageDto.fromRecord(record))
          .toList();
    } catch (e) {
      throw ApiException("خطا در بارگذاری پیام‌ها");
    }
  }

  @override
  Stream<MessageDto> listenToMessages(String chatId) {
    final controller = StreamController<MessageDto>();

    pb.collection('messages').subscribe('*', (e) {
      if (e.action == 'create' && e.record != null) {
        if (e.record!.getStringValue('chat_id') == chatId) {
          controller.add(MessageDto.fromRecord(e.record!));
        }
      }
    });

    controller.onCancel = () {
      pb.collection('messages').unsubscribe('*');
      controller.close();
    };

    return controller.stream;
  }

  @override
  Future<MessageDto> sendMessage({required String chatId, String? text}) async {
    try {
      final body = <String, dynamic>{
        "chat_id": chatId,
        "sender_id": pb.authStore.record?.id,
        "text": text,
      };

      final record = await pb
          .collection('messages')
          .create(body: body, expand: 'sender_id');

      await pb
          .collection('chat')
          .update(chatId, body: {'last_message': record.id});

      return MessageDto.fromRecord(record);
    } catch (e) {
      throw ApiException('پیام ارسال نشد');
    }
  }

  @override
  Future<List<MessageDto>> searchMessage(String chatId, String text) async {
    try {
      final result = await pb
          .collection('messages')
          .getList(
            filter: 'chat_id = "$chatId" && text ~ "$text"',
            expand: 'sender_id',
          );
      return result.items
          .map((record) => MessageDto.fromRecord(record))
          .toList();
    } catch (e) {
      throw ApiException("خطا در جستجوی پیام");
    }
  }
}
