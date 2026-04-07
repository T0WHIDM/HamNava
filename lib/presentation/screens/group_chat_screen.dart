import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

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

  final FocusNode _focusNode = FocusNode();
  MessageEntity? _replyingToMessage;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final ValueNotifier<bool> _showScrollToBottom = ValueNotifier(false);

  late String myUserId;
  List<MessageEntity> _messages = [];
  bool _isLoading = true;
  int _currentPage = 1;
  bool _isFetchingMore = false;
  bool _hasReachedMax = false;
  Timer? _cleanupTimer;

  late final Map<String, UserEntity> _participantsMap;

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _cancelReply() {
    setState(() {
      _replyingToMessage = null;
    });
  }

  void _cancelSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        _focusNode.requestFocus();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.orange.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              content: const Text(
                'توجه: فایل‌های ارسالی شما پس از ۵ دقیقه به صورت خودکار حذف خواهند شد.',
                style: TextStyle(fontFamily: 'CR', color: Colors.white),
                textDirection: TextDirection.rtl,
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      _showErrorSnackBar("خطا در انتخاب عکس");
    }
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _cleanupExpiredMedia();
    });
  }

  void _cleanupExpiredMedia() {
    if (!mounted) return;
    final now = DateTime.now();

    for (var message in _messages.toList()) {
      if (message.attachment != null &&
          message.attachment!.isNotEmpty &&
          message.sender.id == myUserId) {
        final messageTime = message.created.toLocal();
        final difference = now.difference(messageTime).inMinutes;

        if (difference >= 5) {
          context.read<ChatBloc>().add(
            DeleteMessageEvent(message.id, widget.conversation.id),
          );
        }
      }
    }
  }

  Future<void> _saveMediaToGallery(String imageUrl) async {
    try {
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      final tempDir = await getTemporaryDirectory();
      final savePath =
          '${tempDir.path}/group_chat_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await Dio().download(imageUrl, savePath);
      await Gal.putImage(savePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF0ED0D3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: const Text(
              'عکس با موفقیت در گالری ذخیره شد.',
              style: TextStyle(fontFamily: 'CR', color: Colors.black87),
              textDirection: TextDirection.rtl,
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar("خطا در ذخیره عکس: $e");
    }
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

    // شروع بکار رفتگر ۵ دقیقه‌ای پیام‌های عکس‌دار
    _startCleanupTimer();

    _scrollController.addListener(() {
      if (_scrollController.offset > 200) {
        if (!_showScrollToBottom.value) _showScrollToBottom.value = true;
      } else {
        if (_showScrollToBottom.value) _showScrollToBottom.value = false;
      }

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        if (!_isFetchingMore &&
            !_hasReachedMax &&
            widget.conversation.id != null) {
          setState(() {
            _isFetchingMore = true;
          });
          context.read<ChatBloc>().add(
            LoadMoreMessagesEvent(
              chatId: widget.conversation.id,
              page: _currentPage + 1,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel(); // متوقف کردن تایمر قبل از نابودی ویجت
    _messageController.dispose();
    _scrollController.dispose();
    _showScrollToBottom.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? Colors.black : const Color(0xFFF2F2F7);

    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      backgroundColor: scaffoldBg,
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _showScrollToBottom,
        builder: (context, show, child) {
          if (!show) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: FloatingActionButton.small(
              backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              foregroundColor: isDark ? Colors.white : Colors.black87,
              elevation: 4,
              onPressed: _scrollToBottom,
              shape: const CircleBorder(),
              child: const Icon(CupertinoIcons.chevron_down),
            ),
          );
        },
      ),
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
                  _hasReachedMax = messagesFromServer.length < 30;
                  _currentPage = 1;
                });
              },
            );
          }

          if (state is ChatLoadMoreResultState) {
            state.result.fold(
              (failure) => setState(() => _isFetchingMore = false),
              (newMessages) {
                setState(() {
                  if (newMessages.isEmpty || newMessages.length < 30) {
                    _hasReachedMax = true;
                  }
                  _messages.addAll(newMessages);
                  _currentPage++;
                  _isFetchingMore = false;
                });
              },
            );
          }
          if (state is ChatMessageSentResultState) {
            state.result.fold(
              (failure) => _showErrorSnackBar("خطا در ارسال پیام"),
              (success) {
                _messageController.clear();
                _cancelReply();
                _cancelSelectedImage();
              },
            );
          }
          if (state is ChatNewMessageRealTimeState) {
            setState(() {
              if (!_messages.any((m) => m.id == state.result.id)) {
                if (state.result.chatId == widget.conversation.id) {
                  _messages.insert(0, state.result);
                }
              }
            });
          }
          if (state is ChatMessageUpdatedRealtimeState) {
            setState(() {
              final index = _messages.indexWhere(
                (m) => m.id == state.message.id,
              );
              if (index != -1) _messages[index] = state.message;
            });
          }
          if (state is ChatMessageDeletedRealtimeState) {
            setState(() {
              _messages.removeWhere((m) => m.id == state.messageId);
            });
          }
          if (state is DeleteMessageSuccessState) {
            state.result.fold((failure) {
              context.read<ChatBloc>().add(
                LoadMessagesEvent(widget.conversation.id),
              );
              _showErrorSnackBar("خطا در حذف پیام از سرور");
            }, (success) {});
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(child: _buildMessagesList(maxBubbleWidth)),
                _buildMessageInput(isDark),
              ],
            ),
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
          textDirection: TextDirection.rtl,
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
              backgroundColor: const Color(0xFF0ED0D3).withValues(alpha: .2),
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

  Widget _buildMessagesList(double maxBubbleWidth) {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator(radius: 16));
    }

    if (!_isLoading && _messages.isEmpty) {
      return buildEmptyState();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      reverse: true,
      addAutomaticKeepAlives: false,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length + (_isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CupertinoActivityIndicator(radius: 12)),
          );
        }

        final message = _messages[index];
        bool isMe = message.sender.id == myUserId;

        return Dismissible(
          key: Key(message.id),
          direction: isMe
              ? DismissDirection.horizontal
              : DismissDirection.startToEnd,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Icon(
              CupertinoIcons.reply,
              color: isDark ? Colors.white70 : Colors.black54,
              size: 28,
            ),
          ),
          secondaryBackground: isMe
              ? Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: CupertinoColors.destructiveRed,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(CupertinoIcons.delete, color: Colors.white),
                )
              : null,
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              setState(() {
                _replyingToMessage = message;
              });
              _focusNode.requestFocus();
              return false;
            } else if (direction == DismissDirection.endToStart && isMe) {
              context.read<ChatBloc>().add(
                DeleteMessageEvent(message.id, widget.conversation.id),
              );
              return true;
            }
            return false;
          },
          onDismissed: (direction) {
            setState(() => _messages.removeAt(index));
          },
          child: GestureDetector(
            onLongPress: () {
              _showMessageOptions(message, isMe, isDark);
            },
            child: _buildChatBubble(isMe, message, maxBubbleWidth),
          ),
        );
      },
    );
  }

  Widget _buildChatBubble(
    bool isMe,
    MessageEntity message,
    double maxBubbleWidth,
  ) {
    final DateTime time = message.created.toLocal();
    final String formattedTime =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final senderInfo = _participantsMap[message.sender.id];
    final senderName = senderInfo?.name ?? 'کاربر';

    final primaryColor = const Color(0xFF0ED0D3);
    final bubbleBg = isMe
        ? primaryColor
        : (isDark ? const Color(0xFF1C1C1E) : Colors.white);

    String replySenderName = 'کاربر ناشناس';
    bool isReplyToMe = false;

    if (message.replyTo != null) {
      MessageEntity? originalReplyMsg;
      try {
        originalReplyMsg = _messages.firstWhere(
          (m) => m.id == message.replyTo!.id,
        );
      } catch (_) {}

      final replySenderId =
          originalReplyMsg?.sender.id ?? message.replyTo!.sender.id;
      replySenderName =
          originalReplyMsg?.sender.name ?? message.replyTo!.sender.name;
      isReplyToMe = replySenderId == myUserId;
    }

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
          ),
          constraints: BoxConstraints(maxWidth: maxBubbleWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.attachment != null && message.attachment!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: message.attachment!,
                      memCacheWidth: 600,
                      width: maxBubbleWidth - 32,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: maxBubbleWidth - 32,
                        height: 150,
                        color: isDark ? Colors.white10 : Colors.black12,
                        child: const Center(
                          child: CupertinoActivityIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(CupertinoIcons.exclamationmark_triangle),
                    ),
                  ),
                ),

              if (message.replyTo != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 12,
                    top: 4,
                    bottom: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? Colors.black.withValues(alpha: .1)
                        : (isDark
                              ? Colors.white.withValues(alpha: .05)
                              : Colors.black.withValues(alpha: .05)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                      right: BorderSide(
                        color: isMe ? Colors.black54 : const Color(0xFF0ED0D3),
                        width: 4,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isReplyToMe ? 'شما' : replySenderName,
                        style: TextStyle(
                          fontFamily: 'GB',
                          fontSize: 12,
                          color: isMe
                              ? Colors.black87
                              : const Color(0xFF0ED0D3),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message.replyTo!.text ?? 'فایل/تصویر',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'CR',
                          fontSize: 13,
                          color: isMe
                              ? Colors.black87.withValues(alpha: .8)
                              : (isDark
                                    ? Colors.white70
                                    : Colors.black87.withValues(alpha: .8)),
                        ),
                      ),
                    ],
                  ),
                ),

              Align(
                alignment: Alignment
                    .bottomRight, // برای اینکه ساعت همیشه سمت راست پایین باشد
                child: Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    // شرط if فقط برای متن اجرا می‌شود
                    if (message.text != null && message.text!.isNotEmpty) ...[
                      Text(
                        message.text!,
                        style: TextStyle(
                          fontFamily: 'CR',
                          fontSize: 15,
                          height: 1.4,
                          color: isMe
                              ? Colors.black
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 8), // فاصله بین متن و ساعت
                    ],

                    // ساعت پیام (بدون شرط - همیشه رندر می‌شود)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 8),
                      child: Text(
                        formattedTime,
                        style: TextStyle(
                          fontFamily: 'CR',
                          fontSize: 10,
                          color: isMe
                              ? Colors.black54
                              : (isDark ? Colors.white54 : Colors.black54),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ], // پایان
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
    final inputBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;

    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedImage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8, right: 40, left: 40),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: .05)
                      : Colors.black.withValues(alpha: .05),
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      width: 45,
                      height: 45,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'عکس انتخاب شد',
                      style: TextStyle(
                        fontFamily: 'CR',
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      CupertinoIcons.clear_circled_solid,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    onPressed: _cancelSelectedImage,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

          if (_replyingToMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8, right: 40, left: 40),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: .05)
                      : Colors.black.withValues(alpha: .05),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 35,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0ED0D3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _replyingToMessage!.sender.id == myUserId
                              ? 'پاسخ به خودتان'
                              : 'پاسخ به ${_replyingToMessage!.sender.name}',
                          style: const TextStyle(
                            fontFamily: 'GB',
                            fontSize: 12,
                            color: Color(0xFF0ED0D3),
                          ),
                        ),
                        Text(
                          _replyingToMessage!.text ?? 'فایل/تصویر',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'CR',
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      CupertinoIcons.clear_circled_solid,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    onPressed: _cancelReply,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _pickImage,
                  child: Icon(
                    Icons.attach_file_rounded,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    size: 28,
                  ),
                ),
              ),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Container(
                    decoration: BoxDecoration(
                      color: inputBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: .05)
                            : Colors.black.withValues(alpha: .05),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
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
                        isDense: true,
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
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _messageController,
                  builder: (context, value, child) {
                    final hasContent =
                        value.text.trim().isNotEmpty || _selectedImage != null;
                    return GestureDetector(
                      onTap: () {
                        if (hasContent) {
                          context.read<ChatBloc>().add(
                            SendMessageEvent(
                              chatId: widget.conversation.id,
                              text: _messageController.text.trim(),
                              replyId: _replyingToMessage?.id,
                              attachment: _selectedImage,
                            ),
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: hasContent
                              ? const Color(0xFF0ED0D3)
                              : (isDark
                                    ? const Color(0xFF2C2C2E)
                                    : Colors.grey[300]),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.send,
                            color: hasContent
                                ? Colors.black
                                : (isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[500]),
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
              color: const Color(0xFF0ED0D3).withValues(alpha: .1),
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

  void _showMessageOptions(MessageEntity message, bool isMe, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Wrap(
              children: [
                if (message.text != null && message.text!.isNotEmpty)
                  ListTile(
                    leading: Icon(
                      CupertinoIcons.doc_on_clipboard,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    title: Text(
                      'کپی کردن متن',
                      style: TextStyle(
                        fontFamily: 'CR',
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(bottomSheetContext);
                      await Clipboard.setData(
                        ClipboardData(text: message.text!),
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF0ED0D3),
                            content: Text(
                              'متن کپی شد',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontFamily: 'CR',
                                color: Colors.black87,
                              ),
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),

                if (message.attachment != null &&
                    message.attachment!.isNotEmpty)
                  ListTile(
                    leading: Icon(
                      CupertinoIcons.arrow_down_to_line,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    title: Text(
                      'ذخیره در گالری',
                      style: TextStyle(
                        fontFamily: 'CR',
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      _saveMediaToGallery(message.attachment!);
                    },
                  ),

                if (isMe)
                  ListTile(
                    leading: Icon(
                      CupertinoIcons.pencil,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    title: Text(
                      'ویرایش پیام',
                      style: TextStyle(
                        fontFamily: 'CR',
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      _showEditDialog(message);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
