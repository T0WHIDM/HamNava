import 'package:flutter_chat_room_app/data/dtos/conversation_dto.dart';
import 'package:flutter_chat_room_app/data/dtos/message_dto.dart';

abstract class IChatDataSource {
Future<List<ConversationDto>> getAllChat();

Future<List<MessageDto>> getMessages(String chatId);

Future<void> sendMessage({required String text, required String chatId});

Stream<MessageDto> listenToMessage(String chatId);
}