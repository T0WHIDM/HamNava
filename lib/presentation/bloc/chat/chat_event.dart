abstract class ChatEvent {}

class LoadMessagesEvent extends ChatEvent {
  final String chatId;

  LoadMessagesEvent(this.chatId);
}

class SendMessageEvent extends ChatEvent {
  final String chatId;
  final String text;

  SendMessageEvent({required this.chatId, required this.text});
}

class ChatInitializeEvent extends ChatEvent {
  final String targetUserId;
  ChatInitializeEvent(this.targetUserId);
}
