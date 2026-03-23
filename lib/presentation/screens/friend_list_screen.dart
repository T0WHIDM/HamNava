import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_state.dart';
import 'package:flutter_chat_room_app/presentation/screens/chat_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/user_profile_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';
import 'package:pocketbase/pocketbase.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  static String get routeName => 'FriendsListScreen';

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'دوستان من',
          style: TextStyle(fontFamily: 'CR', color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is FriendsListLoadingState) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 14, 208, 211),
              ),
            );
          }

          if (state is FriendListSuccessState) {
            return state.result.fold(
              (failure) {
                return Center(child: Text(failure.message));
              },
              (success) {
                if (success.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  color: const Color.fromARGB(255, 14, 208, 211),
                  onRefresh: () async {
                    final userId = locator<PocketBase>().authStore.record!.id;
                    context.read<UserBloc>().add(FriendListEvent(userId));
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: success.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final friend = success[index];
                      return _buildFriendCard(context, friend);
                    },
                  ),
                );
              },
            );
          }

          return _buildEmptyState(context);
        },
      ),
    );
  }

  Widget _buildFriendCard(BuildContext context, UserEntity friend) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          leading: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return UserProfileScreen(
                      name: friend.name,
                      email: friend.email,
                      userName: friend.userName,
                    );
                  },
                ),
              );
            },
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.cyan.withValues(alpha: 0.2),

              child: const Icon(Icons.person, color: Colors.cyan),
            ),
          ),
          title: Text(
            friend.name,
            style: const TextStyle(fontFamily: 'cr', fontSize: 16),
          ),
          subtitle: Text(
            '@${friend.userName}',
            style: const TextStyle(
              fontFamily: 'CR',
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          trailing: Container(
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.green,
                size: 20,
              ),
              onPressed: () {
                context.pushNamed(
                  ChatScreen.routeName,
                  pathParameters: {'friendId': friend.id},
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return RefreshIndicator(
      color: const Color.fromARGB(255, 14, 208, 211),
      onRefresh: () async {
        final userId = locator<PocketBase>().authStore.record!.id;
        context.read<UserBloc>().add(FriendListEvent(userId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'شما هنوز دوستی اضافه نکرده‌اید.',
                style: TextStyle(
                  fontFamily: 'CR',
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
