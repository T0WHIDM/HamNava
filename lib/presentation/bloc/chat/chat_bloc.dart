import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/get_message_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/private_chat_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/send_message_use_case.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageUseCase _sendMessageUseCase;
  final GetMessageUseCase _getMessageUseCase;
  final PrivateChatUseCase _privateChatUseCase;

  ChatBloc(
    this._sendMessageUseCase,
    this._getMessageUseCase,
    this._privateChatUseCase,
  ) : super(ChatInitialState()) {
    on<ChatInitializeEvent>((event, emit) async {
      emit(ChatLoadingState());
      final result = await _privateChatUseCase.call(event.targetUserId);
      emit(ChatInitializedResultState(result));
    });

    on<LoadMessagesEvent>((event, emit) async {
      // emit(ChatLoadingState());
      final result = await _getMessageUseCase.call(event.chatId);
      emit(ChatMessagesResultState(result));
    });

    on<SendMessageEvent>((event, emit) async {
      final result = await _sendMessageUseCase.call(
        chatId: event.chatId,
        text: event.text,
      );
      emit(ChatMessageSentResultState(result));
      if (result.isRight()) {
        add(LoadMessagesEvent(event.chatId));
      }
    });
  }
}
