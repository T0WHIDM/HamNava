import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/add_friend_to_group_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/create_group_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/delete_chat_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/delete_message_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/edit_message_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/get_all_chat_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/get_message_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/leave_from_group_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/listen_to_message_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/private_chat_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/send_message_use_case.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_state.dart';
import 'package:pocketbase/pocketbase.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageUseCase _sendMessageUseCase;
  final GetMessageUseCase _getMessageUseCase;
  final PrivateChatUseCase _privateChatUseCase;
  final ListenToMessageUseCase _listenMessagesUseCase;
  final DeleteMessageUseCase _deleteMessageUseCase;
  final GetAllChatUseCase _getAllChatUseCase;
  final EditMessageUseCase _editMessageUseCase;
  final DeleteChatUseCase _deleteChatUseCase;
  final CreateGroupUseCase _createGroupUseCase;
  final AddFriendToGroupUseCase _addFriendToGroupUseCase;
  final LeaveFromGroupUseCase _leaveFromGroupUseCase;

  StreamSubscription? _messageSubscription;

  ChatBloc(
    this._sendMessageUseCase,
    this._getMessageUseCase,
    this._privateChatUseCase,
    this._listenMessagesUseCase,
    this._deleteMessageUseCase,
    this._getAllChatUseCase,
    this._editMessageUseCase,
    this._deleteChatUseCase,
    this._createGroupUseCase,
    this._addFriendToGroupUseCase,
    this._leaveFromGroupUseCase,
  ) : super(ChatInitialState()) {
    on<ChatInitializeEvent>((event, emit) async {
      emit(ChatLoadingState());
      final result = await _privateChatUseCase.call(event.targetUserId);
      emit(ChatInitializedResultState(result));
    });

    on<LoadMessagesEvent>((event, emit) async {
      final result = await _getMessageUseCase.call(event.chatId);
      emit(ChatMessagesResultState(result));

      _messageSubscription?.cancel();

      _messageSubscription = _listenMessagesUseCase.call(event.chatId).listen((
        data,
      ) {
        add(
          ChatMessageReceivedFromStreamEvent(
            action: data.action,
            message: data.message,
          ),
        );
      });
    });

    on<LoadMoreMessagesEvent>((event, emit) async {
      final result = await _getMessageUseCase.call(
        event.chatId,
        page: event.page,
      );
      emit(ChatLoadMoreResultState(result));
    });

    on<ChatMessageReceivedFromStreamEvent>((event, emit) {
      if (event.action == 'create') {
        emit(ChatNewMessageRealTimeState(event.message));
      } else if (event.action == 'update') {
        emit(ChatMessageUpdatedRealtimeState(event.message));
      } else if (event.action == 'delete') {
        emit(ChatMessageDeletedRealtimeState(event.message.id));
      }
    });

    on<SendMessageEvent>((event, emit) async {
      final result = await _sendMessageUseCase.call(
        chatId: event.chatId,
        text: event.text,
        replyId: event.replyId,
        attachment: event.attachment,
      );
      emit(ChatMessageSentResultState(result));
    });

    on<DeleteMessageEvent>((event, emit) async {
      var result = await _deleteMessageUseCase.call(
        event.messageId,
        event.chatId,
      );

      emit(DeleteMessageSuccessState(result));
    });

    on<GetChatListEvent>((event, emit) async {
      emit(ChatLoadingState());

      final result = await _getAllChatUseCase.call();

      emit(ChatListSUccessState(result));
    });

    on<EditMessageEvent>((event, emit) async {
      final result = await _editMessageUseCase.call(
        event.messageId,
        event.newText,
      );

      emit(EditMessageSuccessState(result));
    });

    on<DeleteChatEvent>((event, emit) async {
      var result = await _deleteChatUseCase.call(event.chatId);

      emit(DeleteChatSuccessStete(result));
      final userId = locator<PocketBase>().authStore.record!.id;
      add(GetChatListEvent(userId));
    });

    on<CreateGroupChatEvent>((event, emit) async {
      emit(ChatLoadingState());

      var result = await _createGroupUseCase.call(
        event.participants,
        event.chatName,
      );

      emit(CreateGroupSuccessState(result));

      final myUserId = locator<PocketBase>().authStore.record?.id ?? '';
      add(GetChatListEvent(myUserId));
    });

    on<AddFriendToGroupEvent>((event, emit) async {
      emit(ChatLoadingState());

      var result = await _addFriendToGroupUseCase.call(
        event.userId,
        event.chatId,
      );

      emit(AddFriendToGroupSuccessState(result));
    });

    on<LeaveFromGroupEvent>((event, emit) async {
      emit(ChatLoadingState());

      var result = await _leaveFromGroupUseCase.call(
        event.userId,
        event.chatId,
      );

      emit(LeaveFromGroupSuccessState(result));
    });
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
