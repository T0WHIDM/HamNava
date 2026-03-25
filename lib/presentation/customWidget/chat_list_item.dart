import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_event.dart';
import 'package:flutter_chat_room_app/presentation/screens/chat_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';

class ChatListItem extends StatelessWidget {
  final List<ConversationEntity> chatList;
  const ChatListItem(this.chatList, {super.key});

  @override
  Widget build(BuildContext context) {
    if (chatList.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 80,
                color: Colors.grey.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'هیچ گفتگویی ندارید',
                style: TextStyle(
                  fontFamily: 'GB',
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(childCount: chatList.length, (
        context,
        index,
      ) {
        final myUserId = locator<PocketBase>().authStore.record?.id ?? '';

        final participantsList = chatList[index].participants;

        final friendUserEntity = participantsList
            .where((user) => user.id != myUserId)
            .firstOrNull;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
          child: InkWell(
            onTap: () async {
              if (friendUserEntity != null) {
                await context.pushNamed(
                  ChatScreen.routeName,
                  extra: friendUserEntity,
                  pathParameters: {'friendId': friendUserEntity.id},
                );

                if (context.mounted) {
                  final myUserId =
                      locator<PocketBase>().authStore.record?.id ?? '';
                  context.read<ChatBloc>().add(GetChatListEvent(myUserId));
                }
              }
            },

            child: Container(
              width: 180,
              height: 70,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                color: Colors.transparent,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: Color.fromARGB(255, 14, 208, 211),
                      child: Center(
                        child: Icon(FontAwesomeIcons.user, color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            friendUserEntity?.name ?? 'کاربر ناشناس',
                            style: const TextStyle(
                              fontFamily: 'cr',
                              fontSize: 20,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            chatList[index].lastMessage ??
                                'هنوز پیامی ارسال نشده',
                            style: const TextStyle(
                              fontFamily: 'cr',
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
