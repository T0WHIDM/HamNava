import 'dart:async';
import 'dart:io';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/data/dataSource/chatdatasource/chat_data_source.dart';
import 'package:flutter_chat_room_app/data/dtos/conversation_dto.dart';
import 'package:flutter_chat_room_app/data/dtos/message_dto.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

class ChatRemoteDataSourceImpl implements IChatDatasource {
  final PocketBase pb;
  ChatRemoteDataSourceImpl(this.pb);

  @override
  Future<ConversationDto> createOrGetGroupChat({
    required String chatName,
    required List<String> participantIds,
  }) async {
    try {
      final myUserId = locator<PocketBase>().authStore.record?.id ?? '';

      final List<String> finalParticipants = List.from(participantIds);
      if (!finalParticipants.contains(myUserId)) {
        finalParticipants.add(myUserId);
      }

      final body = <String, dynamic>{
        "name": chatName,
        "is_group": true,
        "participants": finalParticipants,
        "admin": [myUserId],
      };

      final record = await pb
          .collection('chat')
          .create(body: body, expand: 'participants,admin');

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
  Future<void> deleteMessage(String messageId, String chatId) async {
    try {
      await pb.collection('messages').delete(messageId);

      final result = await pb
          .collection('messages')
          .getList(
            page: 1,
            perPage: 1,
            filter: 'chat_id = "$chatId"',
            sort: '-created',
          );

      if (result.items.isNotEmpty) {
        final newLastMessageId = result.items.first.id;
        await pb
            .collection('chat')
            .update(chatId, body: {'last_message': newLastMessageId});
      } else {
        await pb
            .collection('chat')
            .update(chatId, body: {'last_message': null});
      }
    } catch (e) {
      throw Exception('خطا در حذف پیام و بروزرسانی چت: $e');
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
      final myUserId = locator<PocketBase>().authStore.record?.id;

      final resultList = await pb
          .collection('chat')
          .getList(
            page: 1,
            perPage: 50,
            sort: '-updated',
            expand: 'participants,last_message,admin',
            filter: 'participants ~ "$myUserId"',
          );

      return resultList.items
          .map((record) => ConversationDto.fromRecord(record))
          .toList();
    } catch (e) {
      throw ApiException("مشکلی در دریافت چت‌ها به وجود آمده است");
    }
  }

  @override
  Future<List<MessageDto>> getMessages(String chatId, {int page = 1}) async {
    try {
      final result = await pb
          .collection('messages')
          .getList(
            perPage: 30,
            page: page,
            filter: 'chat_id = "$chatId"',
            sort: '-created',
            expand: 'sender_id,reply_to',
          );

      return result.items
          .map((record) => MessageDto.fromRecord(record))
          .toList();
    } catch (e) {
      throw ApiException("خطا در بارگذاری پیام‌ها");
    }
  }

  @override
  Stream<({String action, MessageDto message})> listenToMessages(
    String chatId,
  ) {
    final controller =
        StreamController<({String action, MessageDto message})>();

    pb.collection('messages').subscribe('*', (e) {
      if (e.record != null && e.record!.getStringValue('chat_id') == chatId) {
        controller.add((
          action: e.action,
          message: MessageDto.fromRecord(e.record!),
        ));
      }
    }, expand: 'sender_id,reply_to');

    controller.onCancel = () {
      pb.collection('messages').unsubscribe('*');
      controller.close();
    };

    return controller.stream;
  }

  @override
  Future<MessageDto> sendMessage({
    required String chatId,
    String? text,
    String? replyId,
    File? attachment,
  }) async {
    try {
      final body = <String, dynamic>{
        "chat_id": chatId,
        "sender_id": pb.authStore.record?.id,
      };

      if (text != null && text.isNotEmpty) body["text"] = text;

      if (replyId != null) body["reply_to"] = replyId;

      List<http.MultipartFile> files = [];
      if (attachment != null) {
        files.add(await http.MultipartFile.fromPath('file', attachment.path));
      }

      final record = await pb
          .collection('messages')
          .create(body: body, files: files, expand: 'sender_id,reply_to');

      await pb
          .collection('chat')
          .update(chatId, body: {'last_message': record.id});

      return MessageDto.fromRecord(record);
    } catch (e) {
      throw ApiException('پیام ارسال نشد');
    }
  }

  @override
  Future<ConversationDto> addFriendToGroup(String userId, String chatId) async {
    try {
      final body = {'participants+': userId};

      final record = await pb
          .collection('chat')
          .update(chatId, body: body, expand: 'participants');
      return ConversationDto.fromRecord(record);
    } catch (e) {
      throw ApiException('خطا در افزودن عضو به گروه');
    }
  }

  @override
  Future<void> leaveFromGroup(String userId, String chatId) async {
    try {
      final body = {'participants-': userId};

      await pb.collection('chat').update(chatId, body: body);
    } catch (e) {
      throw ApiException('خطا در ترک کردن گروه');
    }
  }
}
