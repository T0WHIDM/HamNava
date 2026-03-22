import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_state.dart';
import 'package:flutter_chat_room_app/presentation/screens/home_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/user_profile_screen.dart';
import 'package:go_router/go_router.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  static String get routeName => 'UserSearchScreen';

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: IconButton(
            onPressed: () {
              context.goNamed(HomeScreen.namedRoute);
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
        ),
        title: const Text(
          'جستجوی دوستان',
          style: TextStyle(fontFamily: 'CR', color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is AddFriendComplatedState) {
            state.result.fold(
              (failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(
                      failure.message,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: 'CR',
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
              (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(
                      'درخواست دوستی ارسال شد',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontFamily: 'CR', color: Colors.white),
                    ),
                  ),
                );
              },
            );
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 22.0,
                vertical: 10,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            context.read<UserBloc>().add(
                              SearchUserEvent(value),
                            );
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'نام کاربری را وارد کنید...',
                          hintStyle: const TextStyle(
                            fontFamily: 'CR',
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          suffixIcon: BlocBuilder<UserBloc, UserState>(
                            buildWhen: (previous, current) =>
                                current is UserSearchLoadingState ||
                                current is AddFriendLoadingState ||
                                current is UserSearchComplatedsState ||
                                current is AddFriendComplatedState,

                            builder: (context, state) {
                              if (state is UserSearchLoadingState ||
                                  state is AddFriendLoadingState) {
                                return const Text('');
                              }
                              if (state is UserSearchLoadingState) {
                                return const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Color.fromARGB(255, 14, 208, 211),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              }
                              return IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {
                                  if (_searchController.text.isNotEmpty) {
                                    context.read<UserBloc>().add(
                                      SearchUserEvent(_searchController.text),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: BlocBuilder<UserBloc, UserState>(
                buildWhen: (previous, current) {
                  return current is! AddFriendLoadingState &&
                      current is! AddFriendComplatedState;
                },
                builder: (context, state) {
                  if (state is UserInitialState) {
                    return buildEmptyState();
                  } else if (state is UserSearchLoadingState) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 14, 208, 211),
                      ),
                    );
                  } else if (state is UserSearchComplatedsState) {
                    return state.result.fold(
                      (exception) => buildErrorWidget(exception.message),
                      (users) => buildUserList(users),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUserList(List<UserEntity> users) {
    if (users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 40),
            SizedBox(height: 15),
            Text(
              'کاربری با این مشخصات پیدا نشد.',
              style: TextStyle(
                fontFamily: 'cr',
                color: Colors.red,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          elevation: 3,
          color: Colors.grey[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return UserProfileScreen(
                        name: user.name,
                        email: user.email,
                        userName: user.userName,
                      );
                    },
                  ),
                );
              },
              child: const CircleAvatar(
                backgroundColor: Color.fromARGB(255, 14, 208, 211),
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
            title: Text(user.name, style: const TextStyle(fontFamily: 'cr')),
            subtitle: Text(
              user.name.isNotEmpty ? '@${user.userName}' : user.email,
              style: const TextStyle(fontFamily: 'cr', fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Color.fromARGB(255, 14, 208, 211),
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.person_add_alt_1_rounded,
                    color: Color.fromARGB(255, 14, 208, 211),
                  ),
                  onPressed: () {
                    context.read<UserBloc>().add(AddFriendEvent(user.id));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(fontFamily: 'GR', color: Colors.red),
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
          Icon(Icons.person_search, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'نام کاربری دوست خود را جستجو کنید',
            style: TextStyle(fontFamily: 'CR', color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
