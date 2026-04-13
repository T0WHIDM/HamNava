import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/constants/color.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_state.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_state.dart';
import 'package:flutter_chat_room_app/presentation/customWidget/custom_snack_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();

  static String get routeName => 'CreateGroupScreen';
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final List<UserEntity> _selectedFriends = [];

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  void _toggleSelection(UserEntity user) {
    setState(() {
      if (_selectedFriends.contains(user)) {
        _selectedFriends.remove(user);
      } else {
        _selectedFriends.add(user);
      }
    });
  }

  void _createGroup() {
    final groupName = _groupNameController.text.trim();

    if (groupName.isEmpty) {
      final snackBar = buildCustomSnackBar(
        title: 'failure',
        message: 'لطفا نام گروه را وارد کنید',
        color: CustomColor.yellow,
        type: .warning,
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
      return;
    }

    if (_selectedFriends.isEmpty) {
      final snackBar = buildCustomSnackBar(
        title: 'failure',
        message: 'حداقل یک عضو را برای افزودن انتخاب کنید',
        color: CustomColor.red,
        type: .failure,
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
      return;
    }

    final pb = locator<PocketBase>();
    final myUserId = pb.authStore.record?.id ?? '';
    final myName = pb.authStore.record?.getStringValue('name') ?? 'من';
    final myUserName = pb.authStore.record?.getStringValue('userName') ?? 'من';
    final myEmail = pb.authStore.record?.getStringValue('email') ?? 'من';

    final myUserEntity = UserEntity(
      id: myUserId,
      name: myName,
      userName: myUserName,
      email: myEmail,
      friends: [],
      // avatar: pb.authStore.record?.getStringValue('avatar') ?? '',
    );

    final List<UserEntity> finalParticipants = List.from(_selectedFriends);
    finalParticipants.add(myUserEntity);

    context.read<ChatBloc>().add(
      CreateGroupChatEvent(
        chatName: groupName,
        participants: finalParticipants,
      ),
    );
    context.read<ChatBloc>().add(GetChatListEvent(myUserId));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark
        ? const Color(0xFF000000)
        : const Color(0xFFF2F2F7);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final primaryColor = const Color(0xFF0ED0D3);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'گروه جدید',
          style: TextStyle(
            fontFamily: 'CR',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is CreateGroupSuccessState) {
            state.groupChat.fold((error) {
              final snackBar = buildCustomSnackBar(
                title: 'failure',
                message: error.message,
                color: CustomColor.red,
                type: .failure,
              );

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(snackBar);
            }, (conversation) => context.pop(conversation));
          }
        },
        builder: (context, state) {
          final isLoading = state is ChatLoadingState;

          return Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextField(
                          controller: _groupNameController,
                          style: TextStyle(
                            fontFamily: 'CR',
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'نام گروه  ...',
                            hintStyle: TextStyle(
                              fontFamily: 'CR',
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[400],
                            ),
                            suffixIcon: Icon(
                              CupertinoIcons.group_solid,
                              color: primaryColor,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: _selectedFriends.isNotEmpty
                        ? SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8.0,
                              ),
                              itemCount: _selectedFriends.length,
                              itemBuilder: (context, index) {
                                final friend = _selectedFriends[index];
                                return GestureDetector(
                                  onTap: () => _toggleSelection(friend),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Column(
                                      children: [
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            CircleAvatar(
                                              radius: 26,
                                              backgroundColor: isDark
                                                  ? Colors.grey[800]
                                                  : Colors.grey[200],
                                              // backgroundImage: friend.avatar.isNotEmpty ? NetworkImage(friend.avatar) : null,
                                              child: Icon(
                                                CupertinoIcons.person_fill,
                                                color: isDark
                                                    ? Colors.grey[500]
                                                    : Colors.grey[400],
                                                size: 28,
                                              ),
                                            ),
                                            Positioned(
                                              top: -4,
                                              right: -4,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: scaffoldBg,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  CupertinoIcons
                                                      .minus_circle_fill,
                                                  size: 22,
                                                  color: CupertinoColors
                                                      .destructiveRed,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        SizedBox(
                                          width: 60,
                                          child: Text(
                                            friend.name,
                                            style: TextStyle(
                                              fontFamily: 'CR',
                                              fontSize: 12,
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 8.0,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'انتخاب اعضا',
                        style: TextStyle(
                          fontFamily: 'CR',
                          fontSize: 14,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: BlocBuilder<UserBloc, UserState>(
                      builder: (context, userState) {
                        if (userState is FriendsListLoadingState) {
                          return const Center(
                            child: CupertinoActivityIndicator(radius: 14),
                          );
                        }

                        if (userState is FriendListSuccessState) {
                          return userState.result.fold(
                            (failure) => const Center(
                              child: Text(
                                'خطا در دریافت لیست',
                                style: TextStyle(fontFamily: 'CR'),
                              ),
                            ),
                            (friendsList) {
                              if (friendsList.isEmpty) {
                                return Center(
                                  child: Text(
                                    'دوستی برای اضافه کردن یافت نشد',
                                    style: TextStyle(
                                      fontFamily: 'CR',
                                      color: isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                );
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListView.separated(
                                    padding: EdgeInsets.zero,
                                    itemCount: friendsList.length,
                                    separatorBuilder: (context, index) =>
                                        Divider(
                                          height: 1,
                                          indent: 64,
                                          color: isDark
                                              ? Colors.white12
                                              : Colors.black.withValues(
                                                  alpha: .05,
                                                ),
                                        ),
                                    itemBuilder: (context, index) {
                                      final friend = friendsList[index];
                                      final isSelected = _selectedFriends
                                          .contains(friend);

                                      return ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 4,
                                            ),
                                        leading: CircleAvatar(
                                          radius: 22,
                                          backgroundColor: isDark
                                              ? Colors.grey[800]
                                              : Colors.grey[200],
                                          child: Icon(
                                            CupertinoIcons.person_fill,
                                            color: isDark
                                                ? Colors.grey[500]
                                                : Colors.grey[400],
                                          ),
                                        ),
                                        title: Text(
                                          friend.name,
                                          style: TextStyle(
                                            fontFamily: 'CR',
                                            fontSize: 16,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        trailing: Icon(
                                          isSelected
                                              ? CupertinoIcons
                                                    .checkmark_circle_fill
                                              : CupertinoIcons.circle,
                                          color: isSelected
                                              ? primaryColor
                                              : (isDark
                                                    ? Colors.grey[600]
                                                    : Colors.grey[300]),
                                          size: 26,
                                        ),
                                        onTap: () => _toggleSelection(friend),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        return const Center(
                          child: Text(
                            'خطا در بارگذاری مخاطبین',
                            style: TextStyle(fontFamily: 'CR'),
                          ),
                        );
                      },
                    ),
                  ),

                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _createGroup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isLoading
                              ? const CupertinoActivityIndicator(
                                  color: Colors.black,
                                )
                              : const Text(
                                  'ایجاد گروه',
                                  style: TextStyle(
                                    fontFamily: 'CR',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (isLoading)
                Container(
                  color: Colors.black.withValues(alpha: .3),
                  child: const Center(
                    child: CupertinoActivityIndicator(radius: 16),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
