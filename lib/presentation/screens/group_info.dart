import 'package:flutter/material.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
import 'package:go_router/go_router.dart';

class GroupInfoScreen extends StatelessWidget {
  final ConversationEntity conversation;

  const GroupInfoScreen({super.key, required this.conversation});

  static String get routeName => 'GroupInfoScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'اطلاعات گروه',
          style: TextStyle(fontFamily: 'cr', fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            backgroundColor: const Color.fromARGB(
              255,
              14,
              208,
              211,
            ).withValues(alpha: 0.2),
            radius: 50,
            child: const Icon(
              Icons.group,
              size: 50,
              color: Color.fromARGB(255, 14, 208, 211),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            conversation.name ?? 'گروه بدون نام',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'cr',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${conversation.participants.length} عضو',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontFamily: 'cr',
            ),
          ),

          const Divider(height: 60, thickness: 2, endIndent: 30, indent: 30),

          Expanded(
            child: ListView.builder(
              itemCount: conversation.participants.length,
              itemBuilder: (context, index) {
                final user = conversation.participants[index];

                final isAdmin = conversation.admin.any(
                  (admin) => admin.id == user.id,
                );

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color.fromARGB(
                      255,
                      14,
                      208,
                      211,
                    ).withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.person,
                      color: Color.fromARGB(255, 14, 208, 211),
                    ),
                  ),
                  title: Text(
                    user.userName,
                    style: const TextStyle(fontFamily: 'cr'),
                  ),
                  // اگر ادمین بود، یک برچسب "مدیر" نشان می‌دهیم
                  trailing: isAdmin
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'مدیر',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'cr',
                            ),
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
