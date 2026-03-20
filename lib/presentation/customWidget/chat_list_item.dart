import 'package:flutter/material.dart';
import 'package:flutter_chat_room_app/presentation/screens/chat_screen.dart';
import 'package:go_router/go_router.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(childCount: 15, (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
          child: InkWell(
            onTap: () {
              context.pushNamed(ChatScreen.routeName);
            },
            child: Container(
              width: 180,
              height: 70,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                color: Colors.transparent,
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  crossAxisAlignment: .center,
                  children: [
                    CircleAvatar(radius: 25, backgroundColor: Colors.cyan),
                    SizedBox(width: 15),
                    Column(
                      mainAxisAlignment: .center,
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          'towhid',
                          style: TextStyle(fontFamily: 'GB', fontSize: 20),
                        ),
                        Text(
                          "سلام خوبی؟ چه خبر؟",
                          style: TextStyle(fontFamily: 'cr', fontSize: 13),
                        ),
                      ],
                    ),
                    Spacer(),
                    Column(
                      children: [
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('23:15'),
                        ),
                      ],
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
