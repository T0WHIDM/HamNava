import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_state.dart';
import 'package:flutter_chat_room_app/presentation/screens/group_info.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';

class GroupChatScreen extends StatefulWidget {
  final ConversationEntity conversation;

  const GroupChatScreen({required this.conversation, super.key});

  static String get routeName => 'GroupChatScreen';

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottom = false;
  late String myUserId;
  List<MessageEntity> _messages = [];
  bool _isLoading = true;

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
    );
  }

  @override
  void initState() {
    super.initState();

    final record = locator<PocketBase>().authStore.record;
    myUserId = record?.id ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatBloc>().add(LoadMessagesEvent(widget.conversation.id));
    });

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
      extendBody: true,
      floatingActionButton: _showScrollToBottom
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: FloatingActionButton.small(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                onPressed: _scrollToBottom,
                child: const Icon(Icons.keyboard_arrow_down),
              ),
            )
          : null,
      appBar: _buildAppBar(context),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          // دریافت پیام‌های اولیه
          if (state is ChatMessagesResultState) {
            state.result.fold(
              (failure) {
                setState(() {
                  _isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(
                      "خطا در دریافت پیام‌ها",
                      style: TextStyle(fontFamily: 'CR'),
                    ),
                  ),
                );
              },
              (messagesFromServer) {
                setState(() {
                  _messages = List.from(messagesFromServer);
                  _isLoading = false;
                });
              },
            );
          }

          // ارسال پیام موفقیت‌آمیز
          if (state is ChatMessageSentResultState) {
            state.result.fold(
              (failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(
                      "خطا در ارسال پیام",
                      style: TextStyle(fontFamily: 'CR'),
                    ),
                  ),
                );
              },
              (success) {
                _messageController.clear();
              },
            );
          }

          // دریافت پیام ریل تایم
          if (state is ChatNewMessageRealTimeState) {
            setState(() {
              if (!_messages.any((m) => m.id == state.result.id)) {
                // اگر پیام مربوط به همین گروه است، اضافه شود
                if (state.result.chatId == widget.conversation.id) {
                  _messages.insert(0, state.result);
                }
              }
            });
          }

          // ادیت پیام ریل تایم
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

          // دلیت پیام ریل تایم
          if (state is ChatMessageDeletedRealtimeState) {
            setState(() {
              _messages.removeWhere((m) => m.id == state.messageId);
            });
          }

          // دلیت پیام (خود کاربر)
          if (state is DeleteMessageSuccessState) {
            state.result.fold((failure) {
              context.read<ChatBloc>().add(
                LoadMessagesEvent(widget.conversation.id),
              );
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

          // ادیت پیام (خود کاربر)
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
              Expanded(child: _buildMessagesList()),
              _buildMessageInput(),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => context.pop(),
      ),
      title: InkWell(
        onTap: () {
          context.pushNamed(
            GroupInfoScreen.routeName,
            extra: widget.conversation, 
          );
        },
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color.fromARGB(
                255,
                14,
                208,
                211,
              ).withValues(alpha: 0.2),
              child: const Icon(
                Icons.group,
                color: Color.fromARGB(255, 14, 208, 211),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.conversation.name ?? 'گروه',
                    style: const TextStyle(fontFamily: 'GB', fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${widget.conversation.participants.length} نفر',
                    style: const TextStyle(
                      fontFamily: 'CR',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_isLoading) {
      return const SpinKitPulsingGrid(
        color: Color.fromARGB(255, 14, 208, 211),
        size: 32,
      );
    }

    if (!_isLoading && _messages.isEmpty) {
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
              DeleteMessageEvent(message.id, widget.conversation.id),
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
            child: _buildChatBubble(isMe, message),
          ),
        );
      },
    );
  }

  Widget _buildChatBubble(bool isMe, MessageEntity message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // final String? avatarUrl = message.sender.avatarUrl;
    // final bool hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    // ویجت نام و حباب پیام
    Widget bubbleAndName = Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        // نمایش نام فرستنده برای پیام‌های دیگران در گروه
        if (!isMe)
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
              bottom: 2,
              top: 4,
              right: 8,
            ),
            child: Text(
              // اگر نام خالی بود، بنویس کاربر ناشناس
              message.sender.name.isNotEmpty
                  ? message.sender.name
                  : 'کاربر ناشناس',
              style: const TextStyle(
                fontFamily: 'CR',
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ),
        Container(
          margin: EdgeInsets.only(bottom: 5, top: isMe ? 5 : 0),
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
            // 🟢 کمی عرض حباب را کم کردیم تا جا برای عکس باز شود
            maxWidth: MediaQuery.of(context).size.width * 0.65,
          ),
          child: Text(
            message.text ?? "",
            style: TextStyle(
              fontFamily: 'CR',
              color: isMe
                  ? Colors.black
                  : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ),
      ],
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
        ), // فاصله از لبه‌های صفحه
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.end, // تا عکس پایین حباب قرار بگیرد
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            // 🟢 نمایش عکس فقط برای دیگران (سمت چپ)
            if (!isMe) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: isDark
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
                // backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
                child: const Icon(Icons.person, size: 20, color: Colors.grey),
              ),
              const SizedBox(width: 8), // فاصله بین عکس و حباب پیام
            ],

            // قرار دادن حباب پیام در Flexible برای جلوگیری از خطای Overflow
            Flexible(child: bubbleAndName),
          ],
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
                    if (_messageController.text.trim().isNotEmpty) {
                      context.read<ChatBloc>().add(
                        SendMessageEvent(
                          chatId: widget.conversation.id,
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
            'پیامی در گروه ندارید، برای شروع صحبت پیام دهید',
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
