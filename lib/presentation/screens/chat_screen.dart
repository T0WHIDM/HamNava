import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_state.dart';
import 'package:flutter_chat_room_app/presentation/screens/user_profile_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';

class ChatScreen extends StatefulWidget {
  final UserEntity friend;

  const ChatScreen(this.friend, {super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();

  static String get routeName => 'ChatScreen';
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottom = false;
  String? _currentChatId;
  late String myUserId;
  List<MessageEntity> _messages = [];
  bool _isLoading = true;

  void _scrollToButton() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();

    final record = locator<PocketBase>().authStore.record;
    myUserId = record?.id ?? '';

    _scrollController.addListener(() {
      if (_scrollController.offset > 200) {
        if (!_showScrollToBottom) {
          setState(() {
            _showScrollToBottom = true;
          });
        }
      } else {
        if (_showScrollToBottom) {
          setState(() {
            _showScrollToBottom = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _showScrollToBottom
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: FloatingActionButton.small(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                onPressed: _scrollToButton,
                child: const Icon(Icons.keyboard_arrow_down),
              ),
            )
          : null,
      extendBody: true,
      appBar: _buildAppBar(context, widget.friend),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          //لود یا ساخت چت روم
          if (state is ChatInitializedResultState) {
            state.result.fold(
              (failure) => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    "خطا در لود چت",
                    style: TextStyle(fontFamily: 'cr'),
                  ),
                ),
              ),
              (conversation) {
                setState(() {
                  _currentChatId = conversation.id;
                });
                context.read<ChatBloc>().add(
                  LoadMessagesEvent(conversation.id),
                );
              },
            );
          }

          //دریافت پیام
          if (state is ChatMessagesResultState) {
            state.result.fold(
              (failure) {
                setState(() {
                  _isLoading = false;
                });
              },
              (messagesFromServer) {
                setState(() {
                  _messages = List.from(messagesFromServer);
                  _isLoading = false;
                });
              },
            );
          }

          // ارسال پیام
          if (state is ChatMessageSentResultState) {
            state.result.fold(
              (failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(
                      "خطا در ارسال پیام",
                      style: TextStyle(fontFamily: 'cr'),
                    ),
                  ),
                );
              },
              (success) {
                _messageController.clear();
              },
            );
          }

          //دریافت پیام ریل تایم
          if (state is ChatNewMessageRealTimeState) {
            setState(() {
              if (!_messages.any((m) => m.id == state.result.id)) {
                _messages.insert(0, state.result);
              }
            });
          }

          //ادیت پیام ریل تایم
          if (state is ChatMessageUpdatedRealtimeState) {
            setState(() {
              final index = _messages.indexWhere(
                (m) => m.id == state.message.id,
              );
              if (index != -1) {
                _messages[index] = state.message;
              }
            });
          }

          //دلیت پیام ریل تایم
          if (state is ChatMessageDeletedRealtimeState) {
            setState(() {
              _messages.removeWhere((m) => m.id == state.messageId);
            });
          }

          //دلیت پیام
          if (state is DeleteMessageSuccessState) {
            state.result.fold((failure) {
              context.read<ChatBloc>().add(LoadMessagesEvent(_currentChatId!));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    "خطا در حذف پیام از سرور",
                    style: TextStyle(fontFamily: 'CR'),
                  ),
                ),
              );
            }, (success) {});
          }

          //ادیت پیام
          if (state is EditMessageSuccessState) {
            state.result.fold((failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    "خطا در ویرایش پیام",
                    style: TextStyle(fontFamily: 'CR'),
                  ),
                ),
              );
            }, (editedMessage) {});
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(child: _buildMessagesList(state)),
              _buildMessageInput(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessagesList(ChatState state) {
    if (_isLoading) {
      return const SpinKitPulsingGrid(
        color: Color.fromARGB(255, 14, 208, 211),
        size: 32,
      );
    }

    if (_isLoading == false && _messages.isEmpty) {
      return buildEmptyState();
    }
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        bool isMe = message.sender.id == myUserId;

        return Dismissible(
          key: Key(message.id),

          direction: isMe ? DismissDirection.endToStart : DismissDirection.none,

          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),

          onDismissed: (direction) {
            setState(() {
              _messages.removeAt(index);
            });

            context.read<ChatBloc>().add(
              DeleteMessageEvent(message.id, message.chatId),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  textDirection: TextDirection.rtl,
                  'پیام حذف شد',
                  style: TextStyle(fontFamily: 'CR'),
                ),
                duration: Duration(seconds: 1),
              ),
            );
          },

          child: GestureDetector(
            onLongPress: () {
              if (isMe) {
                _showEditDialog(message);
              }
            },
            child: _buildChatBubble(isMe, message.text ?? ""),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, UserEntity friend) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () {
          context.pop();
        },
      ),
      elevation: 0,
      title: Row(
        children: [
          InkWell(
            onTap: () {
              context.pushNamed(UserProfileScreen.routeName, extra: friend);
            },
            child: const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(FontAwesomeIcons.user, size: 20, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            widget.friend.name,
            style: const TextStyle(fontFamily: 'GB', fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(bool isMe, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? const Color.fromARGB(255, 14, 208, 211)
              : (isDark ? Colors.grey[800] : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'CR',
            color: isMe
                ? Colors.black
                : (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.attach_file, color: Colors.grey),
                ),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'پیام خود را بنویسید...',
                        hintStyle: TextStyle(fontFamily: 'CR', fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    if (_messageController.text.trim().isNotEmpty &&
                        _currentChatId != null) {
                      context.read<ChatBloc>().add(
                        SendMessageEvent(
                          chatId: _currentChatId!,
                          text: _messageController.text.trim(),
                        ),
                      );
                    }
                  },
                  child: const CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 14, 208, 211),
                    radius: 18,
                    child: Icon(Icons.send, color: Colors.black, size: 18),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'پیامی ندارید, برای شروع مکالمه پیام دهید',
            style: TextStyle(fontFamily: 'CR', color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(MessageEntity message) {
    final TextEditingController editController = TextEditingController(
      text: message.text,
    );

    final chatBloc = context.read<ChatBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'ویرایش پیام',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontFamily: 'CR', fontSize: 16),
          ),
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              controller: editController,
              decoration: InputDecoration(
                hintText: 'متن جدید...',
                hintStyle: const TextStyle(fontFamily: 'CR', fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 14, 208, 211),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'لغو',
                style: TextStyle(fontFamily: 'CR', color: Colors.redAccent),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 14, 208, 211),
                elevation: 0,
              ),
              onPressed: () {
                final newText = editController.text.trim();
                if (newText.isNotEmpty && newText != message.text) {
                  chatBloc.add(EditMessageEvent(message.id, newText));

                  Navigator.pop(dialogContext);
                }
              },
              child: const Text(
                'ذخیره',
                style: TextStyle(fontFamily: 'CR', color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }
}
