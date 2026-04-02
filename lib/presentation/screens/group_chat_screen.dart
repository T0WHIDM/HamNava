import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_state.dart';
import 'package:flutter_chat_room_app/presentation/screens/group_info.dart';
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

  late final Map<String, UserEntity> _participantsMap;

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();

    _participantsMap = {
      for (var user in widget.conversation.participants) user.id: user,
    };

    final pb = locator<PocketBase>();
    myUserId = pb.authStore.record?.id ?? '';
    final myName = pb.authStore.record?.getStringValue('name') ?? 'من';
    final myUserName = pb.authStore.record?.getStringValue('userName') ?? 'من';
    final myEmail = pb.authStore.record?.getStringValue('email') ?? 'من';

    if (!_participantsMap.containsKey(myUserId)) {
      _participantsMap[myUserId] = UserEntity(
        id: myUserId,
        name: myName,
        userName: myUserName,
        email: myEmail,
        friends: [],
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatBloc>().add(LoadMessagesEvent(widget.conversation.id));
    });

    _scrollController.addListener(() {
      if (_scrollController.offset > 200) {
        if (!_showScrollToBottom) {
          setState(() => _showScrollToBottom = true);
        }
      } else {
        if (_showScrollToBottom) {
          setState(() => _showScrollToBottom = false);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? Colors.black : const Color(0xFFF2F2F7);

    return Scaffold(
      backgroundColor: scaffoldBg,
      floatingActionButton: _showScrollToBottom
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: FloatingActionButton.small(
                backgroundColor: isDark
                    ? const Color(0xFF1C1C1E)
                    : Colors.white,
                foregroundColor: isDark ? Colors.white : Colors.black87,
                elevation: 4,
                onPressed: _scrollToBottom,
                shape: const CircleBorder(),
                child: const Icon(CupertinoIcons.chevron_down),
              ),
            )
          : null,
      appBar: _buildAppBar(context, isDark, scaffoldBg),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatMessagesResultState) {
            state.result.fold(
              (failure) {
                setState(() => _isLoading = false);
                _showErrorSnackBar("خطا در دریافت پیام‌ها");
              },
              (messagesFromServer) {
                setState(() {
                  _messages = List.from(messagesFromServer);
                  _isLoading = false;
                });
              },
            );
          } else if (state is ChatMessageSentResultState) {
            state.result.fold(
              (failure) => _showErrorSnackBar("خطا در ارسال پیام"),
              (success) => _messageController.clear(),
            );
          } else if (state is ChatNewMessageRealTimeState) {
            setState(() {
              if (!_messages.any((m) => m.id == state.result.id)) {
                if (state.result.chatId == widget.conversation.id) {
                  _messages.insert(0, state.result);
                }
              }
            });
          } else if (state is ChatMessageUpdatedRealtimeState) {
            setState(() {
              final index = _messages.indexWhere(
                (m) => m.id == state.message.id,
              );
              if (index != -1) _messages[index] = state.message;
            });
          } else if (state is ChatMessageDeletedRealtimeState) {
            setState(() {
              _messages.removeWhere((m) => m.id == state.messageId);
            });
          } else if (state is DeleteMessageSuccessState) {
            state.result.fold((failure) {
              context.read<ChatBloc>().add(
                LoadMessagesEvent(widget.conversation.id),
              );
              _showErrorSnackBar("خطا در حذف پیام از سرور");
            }, (success) {});
          } else if (state is EditMessageSuccessState) {
            state.result.fold(
              (failure) => _showErrorSnackBar("خطا در ویرایش پیام"),
              (editedMessage) {},
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(child: _buildMessagesList()),
              _buildMessageInput(isDark),
            ],
          );
        },
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: CupertinoColors.destructiveRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'CR', color: Colors.white),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, bool isDark, Color bgColor) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: bgColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(CupertinoIcons.back),
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
              backgroundColor: const Color(0xFF0ED0D3).withOpacity(0.2),
              radius: 20,
              child: const Icon(
                CupertinoIcons.group_solid,
                color: Color(0xFF0ED0D3),
                size: 22,
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
                      fontSize: 13,
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
      return const Center(child: CupertinoActivityIndicator(radius: 16));
    }

    if (!_isLoading && _messages.isEmpty) {
      return buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        bool isMe = message.sender.id == myUserId;

        return Dismissible(
          key: Key(message.id),
          direction: isMe ? DismissDirection.endToStart : DismissDirection.none,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: CupertinoColors.destructiveRed,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(CupertinoIcons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            setState(() => _messages.removeAt(index));
            context.read<ChatBloc>().add(
              DeleteMessageEvent(message.id, widget.conversation.id),
            );
          },
          child: GestureDetector(
            onLongPress: () {
              if (isMe) _showEditDialog(message);
            },
            child: _buildChatBubble(isMe, message),
          ),
        );
      },
    );
  }

  Widget _buildChatBubble(bool isMe, MessageEntity message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final senderInfo = _participantsMap[message.sender.id];
    final senderName = senderInfo?.name ?? 'کاربر';

    final primaryColor = const Color(0xFF0ED0D3);
    final bubbleBg = isMe
        ? primaryColor
        : (isDark ? const Color(0xFF1C1C1E) : Colors.white);

    Widget bubbleAndName = Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (!isMe)
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              bottom: 4,
              top: 4,
              right: 12,
            ),
            child: Text(
              (message.sender.name.isNotEmpty ? senderName : 'کاربر ناشناس'),
              style: TextStyle(
                fontFamily: 'CR',
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ),
        Container(
          margin: EdgeInsets.only(bottom: 6, top: isMe ? 6 : 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bubbleBg,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 18),
            ),
            boxShadow: [
              if (!isDark && !isMe)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Text(
            message.text ?? "",
            style: TextStyle(
              fontFamily: 'CR',
              fontSize: 15,
              height: 1.4,
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
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!isMe) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                  child: const Icon(
                    CupertinoIcons.person_fill,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(child: bubbleAndName),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(bool isDark) {
    // رنگ‌بندی مدرن مشابه اپل/تلگرام
    final inputBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;

    return Container(
      // اضافه کردن پدینگ پایین برای فاصله از لبه گوشی‌های مدرن (SafeArea)
      padding: const EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 20),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // دکمه الصاق فایل (استایل آیکون +)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {}, // اکشن الصاق فایل
              child: Icon(
                Icons.attach_file_sharp,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                size: 28,
              ),
            ),
          ),

          // تکست فیلد ورودی
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(
                    fontFamily: 'CR',
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'پیام...',
                    hintStyle: TextStyle(
                      fontFamily: 'CR',
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                    ),
                    border: InputBorder.none,
                    isDense: true, // کوچک کردن ارتفاع پیش‌فرض
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ✅ دکمه ارسال هوشمند (فقط در صورتی روشن می‌شود که متنی تایپ شده باشد)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _messageController,
              builder: (context, value, child) {
                final hasText = value.text.trim().isNotEmpty;
                return GestureDetector(
                  onTap: () {
                    if (hasText) {
                      context.read<ChatBloc>().add(
                        SendMessageEvent(
                          chatId: widget.conversation.id,
                          text: _messageController.text.trim(),
                        ),
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      // اگر متن داشته باشد فیروزه‌ای، در غیر این صورت خاکستری
                      color: hasText
                          ? const Color(0xFF0ED0D3)
                          : (isDark
                                ? const Color(0xFF2C2C2E)
                                : Colors.grey[300]),
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (hasText) // سایه درخشان هنگام تایپ
                          BoxShadow(
                            color: const Color(0xFF0ED0D3).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.send,
                        color: hasText
                            ? Colors.black
                            : (isDark ? Colors.grey[500] : Colors.grey[500]),
                        size: 20,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0ED0D3).withOpacity(0.1),
            ),
            child: const Icon(
              CupertinoIcons.chat_bubble_2_fill,
              size: 60,
              color: Color(0xFF0ED0D3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'پیامی در گروه ندارید',
            style: TextStyle(
              fontFamily: 'cr',
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'برای شروع صحبت پیام دهید',
            style: TextStyle(fontFamily: 'CR', color: Colors.grey[500]),
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
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1C1C1E)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'ویرایش پیام',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontFamily: 'GB', fontSize: 18),
          ),
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              controller: editController,
              decoration: InputDecoration(
                hintText: 'متن جدید...',
                hintStyle: const TextStyle(fontFamily: 'CR', fontSize: 14),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : const Color(0xFFF2F2F7),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
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
                style: TextStyle(
                  fontFamily: 'CR',
                  color: CupertinoColors.destructiveRed,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0ED0D3),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                style: TextStyle(fontFamily: 'CR', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
