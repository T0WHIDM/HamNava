import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/core/constants/color.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_event.dart';
import 'package:flutter_chat_room_app/presentation/customWidget/custom_snack_bar.dart';
import 'package:flutter_chat_room_app/presentation/screens/chat_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/group_chat_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';

class ChatListItem extends StatefulWidget {
  final List<ConversationEntity> chatList;
  const ChatListItem(this.chatList, {super.key});

  @override
  State<ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {
  late List<ConversationEntity> _localChatList;

  @override
  void initState() {
    super.initState();
    _localChatList = List.from(widget.chatList);
  }

  @override
  void didUpdateWidget(ChatListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.chatList != oldWidget.chatList) {
      _localChatList = List.from(widget.chatList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUserId = locator<PocketBase>().authStore.record?.id ?? '';

    return SliverList(
      delegate: SliverChildBuilderDelegate(childCount: _localChatList.length, (
        context,
        index,
      ) {
        final chat = _localChatList[index];

        final friendUserEntity = chat.participants
            .where((user) => user.id != myUserId)
            .firstOrNull;

        bool canDelete = true;
        if (chat.isGroup) {
          canDelete = chat.admin.any((adminUser) => adminUser.id == myUserId);
        }

        return Dismissible(
          key: Key(chat.id),
          direction: canDelete
              ? DismissDirection.endToStart
              : DismissDirection.none,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            setState(() {
              _localChatList.removeAt(index);
            });
            context.read<ChatBloc>().add(DeleteChatEvent(chat.id));

            final snackBar = buildCustomSnackBar(
              title: 'success',
              message: 'گفتگو با موفقیت حذف شد',
              color: CustomColor.green,
              type: .success,
            );

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          },

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
            child: InkWell(
              onTap: () async {
                if (chat.isGroup) {
                  await context.pushNamed(
                    GroupChatScreen.routeName,
                    extra: chat,
                  );
                } else {
                  if (friendUserEntity != null) {
                    await context.pushNamed(
                      ChatScreen.routeName,
                      extra: friendUserEntity,
                      pathParameters: {'friendId': friendUserEntity.id},
                    );
                  }
                }

                if (context.mounted) {
                  final myUserId =
                      locator<PocketBase>().authStore.record?.id ?? '';
                  context.read<ChatBloc>().add(GetChatListEvent(myUserId));
                }
              },

              child: Container(
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
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: const Color.fromARGB(
                          255,
                          14,
                          208,
                          211,
                        ),
                        child: Center(
                          child: Icon(
                            chat.isGroup ? Icons.group : Icons.person_2_rounded,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chat.isGroup
                                  ? chat.name!
                                  : friendUserEntity!.name,
                              style: const TextStyle(
                                fontFamily: 'cr',
                                fontSize: 20,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              chat.lastMessage ?? 'هنوز پیامی ارسال نشده',
                              style: const TextStyle(
                                fontFamily: 'cr',
                                fontSize: 15,
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
          ),
        );
      }),
    );
  }
}
