import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_state.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_state.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.fixed,
          backgroundColor: Colors.red,
          content: Text(
            textDirection: TextDirection.rtl,
            'لطفاً نام گروه را وارد کنید',
            style: TextStyle(fontFamily: 'cr'),
          ),
        ),
      );
      return;
    }

    if (_selectedFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.fixed,
          backgroundColor: Colors.red,
          content: Text(
            textDirection: TextDirection.rtl,
            'حداقل یک نفر را برای گروه انتخاب کنید',
            style: TextStyle(fontFamily: 'cr'),
          ),
        ),
      );
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
    final myUsrId = locator<PocketBase>().authStore.record?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ساخت گروه جدید',
          style: TextStyle(fontFamily: 'cr', fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is CreateGroupSuccessState) {
            state.groupChat.fold(
              (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      error.message,
                      style: const TextStyle(fontFamily: 'cr'),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              (conversation) {
                context.pop(conversation);
              },
            );
          }
        },

        builder: (context, state) {
          final isLoading = state is ChatLoadingState;

          return Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22.0,
                      vertical: 11,
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextField(
                        controller: _groupNameController,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          hintText: 'نام گروه ...',
                          hintStyle: const TextStyle(fontFamily: 'cr'),
                          prefixIcon: const Icon(Icons.group),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: Colors.grey.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: _selectedFriends.isNotEmpty
                        ? SizedBox(
                            height: 110,
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
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
                                      child: SingleChildScrollView(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                CircleAvatar(
                                                  radius: 28,
                                                  backgroundColor: Colors.cyan
                                                      .withValues(alpha: 0.2),
                                                  child: const Icon(
                                                    Icons.person,
                                                    color: Colors.cyan,
                                                    size: 28,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: -2,
                                                  right: -2,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    decoration:
                                                        const BoxDecoration(
                                                          color:
                                                              Colors.redAccent,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            SizedBox(
                                              width: 65,
                                              child: Text(
                                                friend.name,
                                                style: const TextStyle(
                                                  fontFamily: 'cr',
                                                  fontSize: 12,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 8.0,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        ': انتخاب اعضا ',
                        style: TextStyle(
                          fontFamily: 'cr',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: BlocBuilder<UserBloc, UserState>(
                      builder: (context, userState) {
                        if (userState is FriendsListLoadingState) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.cyan,
                            ),
                          );
                        }

                        if (userState is FriendListSuccessState) {
                          return userState.result.fold(
                            (failure) => const Center(
                              child: Text(
                                'خطا در دریافت لیست',
                                style: TextStyle(fontFamily: 'cr'),
                              ),
                            ),
                            (friendsList) {
                              if (friendsList.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'دوستی برای اضافه کردن یافت نشد',
                                    style: TextStyle(fontFamily: 'cr'),
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount: friendsList.length,
                                itemBuilder: (context, index) {
                                  final friend = friendsList[index];
                                  final isSelected = _selectedFriends.contains(
                                    friend,
                                  );

                                  return Padding(
                                    padding: const EdgeInsetsGeometry.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.cyan.withValues(
                                          alpha: 0.2,
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.cyan,
                                        ),
                                      ),
                                      title: Text(
                                        friend.name,
                                        style: const TextStyle(
                                          fontFamily: 'cr',
                                        ),
                                      ),
                                      trailing: Checkbox(
                                        value: isSelected,
                                        activeColor: Colors.cyan,
                                        onChanged: (bool? value) =>
                                            _toggleSelection(friend),
                                      ),
                                      onTap: () => _toggleSelection(friend),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }

                        return const Center(
                          child: Text(
                            'خطا در بارگذاری مخاطبین',
                            style: TextStyle(fontFamily: 'cr'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              if (isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.cyan),
                  ),
                ),
            ],
          );
        },
      ),

      floatingActionButton: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          final isLoading = state is ChatLoadingState;

          return FloatingActionButton.extended(
            onPressed: isLoading ? null : _createGroup,
            backgroundColor: isLoading ? Colors.grey : Colors.cyan,
            icon: const Icon(Icons.done_outline_sharp, color: Colors.white),
            label: const Text(
              'ایجاد گروه',
              style: TextStyle(fontFamily: 'cr', color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
