import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_state.dart';
import 'package:flutter_chat_room_app/presentation/screens/home_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/user_profile_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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

  void _scrollToBottom() {
    _scrollController.animateTo(
      0.0, // Because of reverse: true, 0.0 is the bottom of the list
      duration: const Duration(milliseconds: 300),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scaffoldBg = isDark ? Colors.black : const Color(0xFFF2F2F7);

    return Scaffold(
      backgroundColor: scaffoldBg,
      floatingActionButton: _showScrollToBottom
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: FloatingActionButton.small(
                backgroundColor: isDark
                    ? const Color(0xFF2C2C2E)
                    : Colors.white,
                foregroundColor: isDark ? Colors.white : Colors.black87,
                elevation: 4,
                shape: const CircleBorder(),
                onPressed: _scrollToBottom,
                child: const Icon(CupertinoIcons.chevron_down),
              ),
            )
          : null,
      appBar: _buildAppBar(context, widget.friend, isDark, scaffoldBg),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          // لود یا ساخت چت روم
          if (state is ChatInitializedResultState) {
            state.result.fold(
              (failure) => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    "خطا در لود چت",
                    style: TextStyle(fontFamily: 'CR'),
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

          // دریافت پیام
          if (state is ChatMessagesResultState) {
            state.result.fold((failure) => setState(() => _isLoading = false), (
              messagesFromServer,
            ) {
              setState(() {
                _messages = List.from(messagesFromServer);
                _isLoading = false;
              });
            });
          }

          // ارسال پیام
          if (state is ChatMessageSentResultState) {
            state.result.fold(
              (failure) => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    "خطا در ارسال پیام",
                    style: TextStyle(fontFamily: 'CR'),
                  ),
                ),
              ),
              (success) => _messageController.clear(),
            );
          }

          // دریافت پیام ریل تایم
          if (state is ChatNewMessageRealTimeState) {
            setState(() {
              if (!_messages.any((m) => m.id == state.result.id)) {
                _messages.insert(0, state.result);
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

          // دلیت پیام
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

          // ادیت پیام
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
          return SafeArea(
            child: Column(
              children: [
                Expanded(child: _buildMessagesList(state, isDark)),
                _buildMessageInput(isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessagesList(ChatState state, bool isDark) {
    if (_isLoading) {
      return const Center(
        child: SpinKitPulsingGrid(color: Color(0xFF0ED0D3), size: 32),
      );
    }

    if (_messages.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      reverse: true, // Scroll starts from bottom
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: CupertinoColors.destructiveRed,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              CupertinoIcons.delete,
              color: Colors.white,
              size: 24,
            ),
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
                backgroundColor: CupertinoColors.destructiveRed,
                content: Text(
                  'پیام حذف شد',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontFamily: 'CR'),
                ),
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: GestureDetector(
            onLongPress: () {
              if (isMe) _showEditDialog(message);
            },
            child: _buildChatBubble(isMe, message.text ?? "", isDark),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    UserEntity friend,
    bool isDark,
    Color scaffoldbg,
  ) {
    return AppBar(
      backgroundColor: scaffoldbg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(
          CupertinoIcons.back,
          color: isDark ? Colors.white : Colors.black87,
        ),
        onPressed: () => context.goNamed(HomeScreen.namedRoute),
      ),
      title: GestureDetector(
        onTap: () =>
            context.pushNamed(UserProfileScreen.routeName, extra: friend),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
              child: Icon(
                CupertinoIcons.person_fill,
                size: 20,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                friend.name,
                style: TextStyle(
                  fontFamily: 'GB',
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(bool isMe, String text, bool isDark) {
    final myBubbleColor = const Color(0xFF0ED0D3);
    final otherBubbleColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isMe
        ? Colors.black87
        : (isDark ? Colors.white : Colors.black87);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // ✅ مشکل رنگ حل شد: حالا پیام‌های طرف مقابل رنگ مخصوص خود را دارند
          color: isMe ? myBubbleColor : otherBubbleColor,
          gradient: isMe
              ? const LinearGradient(
                  colors: [Color(0xFF0ED0D3), Color(0xFF0CB8B9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          boxShadow: [
            if (!isDark &&
                !isMe) // فقط برای پیام طرف مقابل در حالت روز سایه ملایم می‌اندازیم
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
          ],
          // گوشه‌های پریمیوم به سبک iMessage
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'CR',
            fontSize: 15,
            height: 1.3,
            color: textColor,
          ),
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
                    if (hasText && _currentChatId != null) {
                      context.read<ChatBloc>().add(
                        SendMessageEvent(
                          chatId: _currentChatId!,
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.chat_bubble_2_fill,
              size: 64,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'پیامی ندارید',
            style: TextStyle(
              fontFamily: 'CR',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'برای شروع مکالمه پیامی بنویسید',
            style: TextStyle(
              fontFamily: 'CR',
              fontSize: 14,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'ویرایش پیام',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'CR',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              controller: editController,
              autofocus: true,
              style: TextStyle(
                fontFamily: 'CR',
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'متن جدید...',
                hintStyle: TextStyle(
                  fontFamily: 'CR',
                  color: Colors.grey.shade500,
                ),
                filled: true,
                fillColor: isDark ? Colors.black : const Color(0xFFF2F2F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF0ED0D3),
                    width: 1.5,
                  ),
                ),
              ),
              minLines: 1,
              maxLines: 5,
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
                  borderRadius: BorderRadius.circular(8),
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
