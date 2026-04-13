import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/constants/color.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_state.dart';
import 'package:flutter_chat_room_app/presentation/customWidget/custom_snack_bar.dart';
import 'package:flutter_chat_room_app/presentation/screens/home_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/user_profile_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../customWidget/video_player.dart';

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
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  MessageEntity? _replyingToMessage;
  File? _selectedAttachment;
  bool _showScrollToBottom = false;
  String? _currentChatId;
  late String myUserId;
  late String pbBaseUrl;
  List<MessageEntity> _messages = [];
  bool _isLoading = true;
  int _currentPage = 1;
  bool _isFetchingMore = false;
  bool _hasReachedMax = false;

  Timer? _cleanupTimer;

  bool _isVideoFile(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv'].contains(ext);
  }

  Future<void> _pickMedia() async {
    try {
      final XFile? media = await _picker.pickMedia(imageQuality: 50);

      if (media == null) {
        return;
      }

      setState(() {
        _selectedAttachment = File(media.path);
      });

      if (mounted) {
        showDialog(
          context: context,
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
              actions: [
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0ED0D3),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'فهمیدم',
                      style: TextStyle(fontFamily: 'cr', color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      debugPrint('خطای در انتخاب فایل');
    }
  }

  void _cancelAttachment() {
    setState(() {
      _selectedAttachment = null;
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _cancelReply() {
    setState(() {
      _replyingToMessage = null;
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
    final snackBar = buildCustomSnackBar(
      title: 'waiting ...',
      message: 'درحال دانلود و ذخیره در گالری',
      color: CustomColor.yellow,
      type: .warning,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);

    try {
      final tempDir = await getTemporaryDirectory();
      final savePath = "${tempDir.path}/$fileName";

      await Dio().download(fileUrl, savePath);

      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        hasAccess = await Gal.requestAccess();
      }

      if (hasAccess) {
        final isVideo =
            fileName.toLowerCase().endsWith('.mp4') ||
            fileName.toLowerCase().endsWith('.mov');

        if (isVideo) {
          await Gal.putVideo(savePath);
        } else {
          await Gal.putImage(savePath);
        }

        if (mounted) {
          final snackBar = buildCustomSnackBar(
            title: 'success',
            message: 'با موفقیت در گالری ذخیره شد ',
            color: CustomColor.green,
            type: .success,
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        }
      } else {
        if (mounted) {
          final snackBar = buildCustomSnackBar(
            title: 'failure',
            message: 'دسترسی به گالری داده نشد',
            color: CustomColor.red,
            type: .failure,
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        }
      }
    } catch (e) {
      if (mounted) {
        final snackBar = buildCustomSnackBar(
          title: 'failure',
          message: 'خطا در ذخیره $e',
          color: CustomColor.red,
          type: .failure,
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    final pb = locator<PocketBase>();
    myUserId = pb.authStore.record?.id ?? '';
    pbBaseUrl = pb.baseURL;

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

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        if (!_isFetchingMore && !_hasReachedMax && _currentChatId != null) {
          setState(() {
            _isFetchingMore = true;
          });
          context.read<ChatBloc>().add(
            LoadMoreMessagesEvent(
              chatId: _currentChatId!,
              page: _currentPage + 1,
            ),
          );
        }
      }
    });

    _cleanupTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _cleanupExpiredMedia();
    });
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
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
          if (state is ChatInitializedResultState) {
            state.result.fold(
              (failure) {
                final snackBar = buildCustomSnackBar(
                  title: 'failure',
                  message: 'خطا در لود چت',
                  color: CustomColor.red,
                  type: .failure,
                );

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(snackBar);
              },
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

          if (state is ChatMessagesResultState) {
            state.result.fold((failure) => setState(() => _isLoading = false), (
              messagesFromServer,
            ) {
              setState(() {
                _messages = List.from(messagesFromServer);
                _hasReachedMax = messagesFromServer.length < 30;
                _currentPage = 1;
                _isLoading = false;
              });
            });
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
                _messages.insert(0, state.result);
              }
            });
          }

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

          if (state is ChatMessageDeletedRealtimeState) {
            setState(() {
              _messages.removeWhere((m) => m.id == state.messageId);
            });
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(child: _buildMessagesList(state, isDark)),
                    _buildMessageInput(isDark),
                  ],
                ),
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
      reverse: true,
      addAutomaticKeepAlives: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length + (_isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SpinKitPulsingGrid(color: Color(0xFF0ED0D3), size: 20),
            ),
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
                DeleteMessageEvent(message.id, message.chatId),
              );
              return true;
            }
            return false;
          },
          onDismissed: (direction) {
            setState(() {
              _messages.removeAt(index);
            });
          },
          child: GestureDetector(
            onLongPress: () {
              _showMessageOptions(message, isMe, isDark);
            },
            child: _buildChatBubble(message, isMe, isDark),
          ),
        );
      },
    );
  }

  Widget _buildChatBubble(MessageEntity message, bool isMe, bool isDark) {
    final DateTime time = message.created.toLocal();
    final String formattedTime =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    final myBubbleColor = const Color(0xFF0ED0D3);
    final otherBubbleColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isMe
        ? Colors.black87
        : (isDark ? Colors.white : Colors.black87);

    final hasAttachment =
        message.attachment != null && message.attachment!.isNotEmpty;
    final isVideo = hasAttachment && _isVideoFile(message.attachment!);

    final fileUrl = hasAttachment
        ? '$pbBaseUrl/api/files/messages/${message.id}/${message.attachment}'
        : null;

    final imageUrl = hasAttachment && !isVideo ? '$fileUrl?thumb=300x0' : null;

    String replySenderName = '';
    if (message.replyTo != null) {
      final originalMsg = _messages
          .where((m) => m.id == message.replyTo!.id)
          .firstOrNull;
      final actualSenderId =
          originalMsg?.sender.id ?? message.replyTo!.sender.id;

      replySenderName = (actualSenderId == myUserId)
          ? 'شما'
          : widget.friend.name;
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? myBubbleColor : otherBubbleColor,
          gradient: isMe
              ? const LinearGradient(
                  colors: [Color(0xFF0ED0D3), Color(0xFF0CB8B9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
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
                      replySenderName,
                      style: TextStyle(
                        fontFamily: 'GB',
                        fontSize: 12,
                        color: isMe ? Colors.black87 : const Color(0xFF0ED0D3),
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
                        color: textColor.withValues(alpha: .8),
                      ),
                    ),
                  ],
                ),
              ),

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
                    memCacheWidth: 400,
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const SizedBox(
                      height: 150,
                      child: Center(
                        child: SpinKitPulse(color: Colors.white, size: 30),
                      ),
                    ),
                    errorWidget: (context, url, error) => const SizedBox(
                      height: 150,
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            if (message.text != null && message.text!.isNotEmpty)
              Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  Text(
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
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      formattedTime,
                      style: TextStyle(
                        fontFamily: 'GB',
                        fontSize: 12,
                        color: isMe
                            ? Colors.black54
                            : (isDark ? Colors.white54 : Colors.black54),
                      ),
                    ),
                  ),
                ],
              ),
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
              padding: const EdgeInsets.all(8),
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
                        color: isDark ? Colors.white70 : Colors.black54,
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
                  onPressed: () {
                    _pickMedia();
                  },
                  child: Icon(
                    Icons.attach_file_sharp,
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
                    final hasText = value.text.trim().isNotEmpty;
                    final hasAttachment = _selectedAttachment != null;
                    final canSend = (hasText || hasAttachment);

                    return GestureDetector(
                      onTap: () {
                        if (canSend && _currentChatId != null) {
                          context.read<ChatBloc>().add(
                            SendMessageEvent(
                              chatId: _currentChatId!,
                              text: hasText
                                  ? _messageController.text.trim()
                                  : null,
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
                          color: canSend
                              ? const Color(0xFF0ED0D3)
                              : (isDark
                                    ? const Color(0xFF2C2C2E)
                                    : Colors.grey[300]),
                          shape: BoxShape.circle,
                          boxShadow: [
                            if (canSend)
                              BoxShadow(
                                color: const Color(
                                  0xFF0ED0D3,
                                ).withValues(alpha: .3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.send,
                            color: canSend ? Colors.black : Colors.grey[500],
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

  void _showMessageOptions(MessageEntity message, bool isMe, bool isDark) {
    final hasAttachment =
        message.attachment != null && message.attachment!.isNotEmpty;
    final fileUrl = hasAttachment
        ? '$pbBaseUrl/api/files/messages/${message.id}/${message.attachment}'
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
