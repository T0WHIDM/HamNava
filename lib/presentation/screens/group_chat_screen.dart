import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_chat_room_app/constants/color.dart';
import 'package:flutter_chat_room_app/presentation/customWidget/custom_snack_bar.dart';
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

import '../customWidget/video_player.dart';

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
  File? _selectedAttachment;
  final ImagePicker _picker = ImagePicker();
  final ValueNotifier<bool> _showScrollToBottom = ValueNotifier(false);
  late String myUserId;
  late String pbBaseUrl;
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

  bool _isVideoFile(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv'].contains(ext);
  }

  void _cancelAttachment() {
    setState(() {
      _selectedAttachment = null;
    });
  }

  Future<void> _pickMedia() async {
    try {
      final XFile? media = await _picker.pickMedia(imageQuality: 50);

      if (media == null) {
        return;
      }

      final isVideo = _isVideoFile(media.path);

      if (isVideo && mounted) {
        final bool? shouldSelect = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'توجه',
                    style: TextStyle(
                      fontFamily: 'cr',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                ],
              ),
              content: const Text(
                'در این بخش تنها امکان ارسال عکس و ویدیو وجود دارد. فایل‌های ارسالی پس از ۵ دقیقه به صورت خودکار حذف خواهند شد. همچنین حداکثر حجم مجاز برای هر فایل ۵۰ مگابایت می‌باشد.',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(fontFamily: 'cr'),
              ),
              actionsAlignment: MainAxisAlignment.start,
              actions: [
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0ED0D3),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text(
                      'تایید',
                      style: TextStyle(fontFamily: 'cr', color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        );

        if (shouldSelect != true) {
          return;
        }
      }

      setState(() {
        _selectedAttachment = File(media.path);
      });
    } catch (e) {
      debugPrint('خطا در انتخاب فایل: $e');
    }
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _cleanupExpiredMedia();
    });
  }

  void _cleanupExpiredMedia() {
    if (_messages.isEmpty) return;

    final now = DateTime.now();

    final messagesToCheck = List<MessageEntity>.from(_messages);

    for (var message in messagesToCheck) {
      if (message.attachment != null && message.attachment!.isNotEmpty) {
        final msgTime = message.created.toLocal();
        final difference = now.difference(msgTime);

        if (difference.inSeconds >= 300) {
          context.read<ChatBloc>().add(
            DeleteMessageEvent(message.id, message.chatId),
          );
        }
      }
    }
  }

  Future<void> _saveMediaToGallery(String fileUrl, String fileName) async {
    try {
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        hasAccess = await Gal.requestAccess();
      }

      if (hasAccess) {
        final isVideo = _isVideoFile(fileName);
        final tempDir = await getTemporaryDirectory();
        final savePath =
            '${tempDir.path}/group_chat_${DateTime.now().millisecondsSinceEpoch}.${isVideo ? 'mp4' : 'jpg'}';

        await Dio().download(fileUrl, savePath);

        if (isVideo) {
          await Gal.putVideo(savePath);
        } else {
          await Gal.putImage(savePath);
        }

        if (mounted) {
          final snackBar = buildCustomSnackBar(
            title: 'success',
            message: isVideo
                ? 'ویدیو با موفقیت در گالری ذخیره شد.'
                : 'عکس با موفقیت در گالری ذخیره شد.',
            color: CustomColor.green,
            type: .success,
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        }
      }
    } catch (e) {
      final snackBar = buildCustomSnackBar(
        title: 'failure',
        message: 'خطا در ذخیره فایل $e',
        color: CustomColor.red,
        type: .failure,
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
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
    pbBaseUrl = pb.baseURL;
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

    _startCleanupTimer();

    _scrollController.addListener(() {
      if (_scrollController.offset > 200) {
        if (!_showScrollToBottom.value) _showScrollToBottom.value = true;
      } else {
        if (_showScrollToBottom.value) _showScrollToBottom.value = false;
      }

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        if (!_isFetchingMore && !_hasReachedMax) {
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
    _cleanupTimer?.cancel();
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
                final snackBar = buildCustomSnackBar(
                  title: 'failure',
                  message: 'خطا در دریافت پیام ها',
                  color: CustomColor.red,
                  type: .failure,
                );

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(snackBar);
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
              (failure) {
                final snackBar = buildCustomSnackBar(
                  title: 'failure',
                  message: 'خطا در ارسال پیام',
                  color: CustomColor.red,
                  type: .failure,
                );

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(snackBar);
              },
              (success) {
                _messageController.clear();
                _cancelReply();
                _cancelAttachment();
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
              final snackBar = buildCustomSnackBar(
                title: 'failure',
                message: 'خطا در حذف پیام از سرور',
                color: CustomColor.red,
                type: .failure,
              );

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(snackBar);
              ;
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

    final hasAttachment =
        message.attachment != null && message.attachment!.isNotEmpty;
    final isVideo = hasAttachment && _isVideoFile(message.attachment!);

    final fileUrl = hasAttachment
        ? (message.attachment!.startsWith('http')
              ? message.attachment!
              : '$pbBaseUrl/api/files/messages/${message.id}/${message.attachment}')
        : null;

    final imageUrl = hasAttachment && !isVideo ? '$fileUrl?thumb=300x0' : null;

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
              // <--- بخش نمایش ویدیو
              if (hasAttachment && isVideo)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: VideoPlayerWidget(videoUrl: fileUrl!),
                  ),
                ),

              if (hasAttachment && !isVideo)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl ?? fileUrl!,
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
                alignment: Alignment.bottomRight,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
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
                      const SizedBox(width: 8),
                    ],
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
            ],
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
          if (_selectedAttachment != null)
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
                    child: _isVideoFile(_selectedAttachment!.path)
                        ? Container(
                            height: 45,
                            width: 45,
                            color: Colors.black12,
                            child: const Icon(
                              Icons.videocam,
                              color: Colors.grey,
                            ),
                          )
                        : Image.file(
                            _selectedAttachment!,
                            height: 45,
                            width: 45,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isVideoFile(_selectedAttachment!.path)
                          ? 'ویدیو انتخاب شد'
                          : 'عکس انتخاب شد',
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
                    onPressed: _cancelAttachment,
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
                  onPressed: _pickMedia,
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
                        value.text.trim().isNotEmpty ||
                        _selectedAttachment != null;
                    return GestureDetector(
                      onTap: () {
                        if (hasContent) {
                          context.read<ChatBloc>().add(
                            SendMessageEvent(
                              chatId: widget.conversation.id,
                              text: _messageController.text.trim(),
                              replyId: _replyingToMessage?.id,
                              attachment: _selectedAttachment,
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
    final hasAttachment =
        message.attachment != null && message.attachment!.isNotEmpty;
    final fileUrl = hasAttachment
        ? (message.attachment!.startsWith('http')
              ? message.attachment!
              : '$pbBaseUrl/api/files/messages/${message.id}/${message.attachment}')
        : null;

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
                        final snackBar = buildCustomSnackBar(
                          title: 'success',
                          message: 'متن کپی شد',
                          color: CustomColor.green,
                          type: .success,
                        );

                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(snackBar);
                      }
                    },
                  ),

                if (hasAttachment)
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
                      _saveMediaToGallery(fileUrl!, message.attachment!);
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
