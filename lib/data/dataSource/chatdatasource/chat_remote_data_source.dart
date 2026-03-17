import 'dart:async';
import 'package:flutter_chat_room_app/data/dataSource/chatdatasource/chat_data_source.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_chat_room_app/core/exeption/api_exeption.dart';
import 'package:flutter_chat_room_app/data/dtos/conversation_dto.dart';
import 'package:flutter_chat_room_app/data/dtos/message_dto.dart';

class ChatDataSourceImpl implements IChatDataSource {
  final PocketBase pb;

  ChatDataSourceImpl(this.pb);

  @override
  Future<List<ConversationDto>> getAllChat() async {
    try {
      // گرفتن لیست کامل چت‌ها
      final records = await pb
          .collection('chat')
          .getFullList(
            sort: '-created', // مرتب‌سازی از جدیدترین
          );

      return records
          .map((record) => ConversationDto.fromRecord(record))
          .toList();
    } catch (e) {
      throw ApiExeption('خطا در دریافت لیست چت‌ها: $e');
    }
  }

  @override
  Future<List<MessageDto>> getMessages(String chatId) async {
    try {
      // گرفتن پیام‌های یک چت خاص همراه با اطلاعات فرستنده (expand)
      final records = await pb
          .collection('messages')
          .getFullList(
            filter: 'chat_id = "$chatId"',
            expand: 'sender_id',
            sort:
                'created', // مرتب‌سازی از قدیمی‌ترین به جدیدترین برای نمایش در چت
          );

      return records.map((record) => MessageDto.fromRecord(record)).toList();
    } catch (e) {
      throw ApiExeption('خطا در دریافت پیام‌ها: $e');
    }
  }

  @override
  Future<void> sendMessage({
    required String text,
    required String chatId,
  }) async {
    try {
      // گرفتن آی‌دی کاربر لاگین شده از خود پاکت‌بیس
      final currentUserId = pb.authStore.record?.id;
      if (currentUserId == null) throw Exception("کاربر لاگین نیست");

      final body = {
        'text': text,
        'chat_id': chatId,
        'sender_id': currentUserId, // فرستنده خودِ کاربر است
      };

      await pb.collection('messages').create(body: body);
    } catch (e) {
      throw ApiExeption('خطا در ارسال پیام: $e');
    }
  }

  @override
  Stream<MessageDto> listenToMessage(String chatId) {
    // استفاده از StreamController برای تبدیل کالبکِ پاکت‌بیس به استریم
    late StreamController<MessageDto> controller;

    controller = StreamController<MessageDto>(
      onListen: () async {
        try {
          // سابسکرایب کردن روی کالکشن messages با قابلیت expand
          await pb.collection('messages').subscribe('*', (e) {
            // فقط پیام‌های جدید و فقط مربوط به همین چت را فیلتر می‌کنیم
            if (e.action == 'create' &&
                e.record?.getStringValue('chat_id') == chatId) {
              if (e.record != null) {
                final newDto = MessageDto.fromRecord(e.record!);
                controller.add(newDto); // ارسال پیام جدید به استریم
              }
            }
          }, expand: 'sender_id'); // بسیار مهم: اینجا هم باید expand را بنویسی!
        } catch (e) {
          controller.addError(ApiExeption('خطا در اتصال زنده: $e'));
        }
      },
      onCancel: () {
        // قطع اتصال وقتی کاربر از صفحه چت خارج می‌شود
        pb.collection('messages').unsubscribe('*');
        controller.close();
      },
    );

    return controller.stream;
  }
}
