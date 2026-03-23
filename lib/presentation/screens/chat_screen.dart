import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_state.dart';
import 'package:flutter_chat_room_app/presentation/screens/user_profile_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';

class ChatScreen extends StatefulWidget {
  final String friendId;
  const ChatScreen(this.friendId, {super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();

  static String get routeName => 'ChatScreen';
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? _currentChatId;
  late String myUserId;
  List<MessageEntity> _messages = [];

  @override
  void initState() {
    super.initState();

    final record = locator<PocketBase>().authStore.record;
    myUserId = record?.id ?? '';
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: _buildAppBar(context),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatInitializedResultState) {
            state.result.fold(
              (failure) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("خطا در لود چت: ${failure.message}")),
              ),
              (conversation) {
                setState(() {
                  _currentChatId =
                      conversation.id; // آیدی چت اینجا ذخیره می‌شود
                });
                // بعد از گرفتن آیدی، پیام‌ها را لود کن
                context.read<ChatBloc>().add(
                  LoadMessagesEvent(conversation.id),
                );
              },
            );
          }
          if (state is ChatMessageSentResultState) {
            state.result.fold(
              (failure) {
                // فقط اگر واقعاً شکست خورد خطا نشان بده
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("خطا در ارسال پیام: ${failure.message}"),
                  ),
                );
              },
              (success) {
                // اگر موفق بود، فیلد متن را خالی کن (نیازی به نشان دادن مسیج موفقیت نیست)
                _messageController.clear();
              },
            );
          }
        },
        builder: (context, state) {
          // آپدیت کردن لیست محلی در صورت موفقیت
          if (state is ChatMessagesResultState) {
            state.result.fold((failure) => null, (messagesFromServer) {
              _messages = messagesFromServer; // لیست را بروزرسانی کن
            });
          }

          return Column(
            children: [
              Expanded(
                child: _buildMessagesList(
                  state,
                ), // پاس دادن استیت برای مدیریت لودینگ/خالی بودن
              ),
              _buildMessageInput(),
            ],
          );
        },
      ),
    );
  }

  // بخش لیست پیام‌ها با مدیریت Either
  Widget _buildMessagesList(ChatState state) {
    // اگر در حال لود اولیه هستیم و لیستی نداریم
    if (state is ChatLoadingState && _messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // اگر لیست خالی است
    if (_messages.isEmpty) {
      return buildEmptyState();
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        bool isMe = message.sender.id == myUserId;
        return _buildChatBubble(isMe, message.text ?? "");
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () {
          context.pop();
        },
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      title: Row(
        children: [
          InkWell(
            onTap: () {
              context.pushNamed(UserProfileScreen.routeName);
            },
            child: const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(FontAwesomeIcons.user, size: 20, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Towhid', // بعدا می‌توانید نام کاربر را از دیتابیس بگیرید
            style: TextStyle(fontFamily: 'GB', fontSize: 16),
          ),
        ],
      ),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
      ],
    );
  }

  Widget _buildChatBubble(bool isMe, String text) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color.fromARGB(255, 14, 208, 211) : Colors.white,
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
          text, // نمایش متن واقعی پیام
          style: TextStyle(
            fontFamily: 'CR',
            color: isMe ? Colors.black : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.grey.shade300),
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
                    // اتصال دکمه ارسال به بلاک
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
}
