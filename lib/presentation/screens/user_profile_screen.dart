import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';
import 'package:flutter_chat_room_app/presentation/screens/chat_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/home_screen.dart';
import 'package:go_router/go_router.dart';

class UserProfileScreen extends StatelessWidget {
  final UserEntity? user;

  const UserProfileScreen(this.user, {super.key});

  static String get routeName => 'UserProfileScreen';

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.goNamed(HomeScreen.namedRoute);
        }
      });
      return const Scaffold(body: Center(child: CupertinoActivityIndicator()));
    }

    final nonNullUser = user!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark
        ? const Color(0xFF000000)
        : const Color(0xFFF2F2F7);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final primaryColor = const Color(0xFF0ED0D3);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              expandedHeight: 340,
              stretch: true,
              pinned: true,
              backgroundColor: scaffoldBg,
              surfaceTintColor: Colors.transparent,
              leading: Padding(
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: .4),
                    child: const Icon(
                      CupertinoIcons.back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primaryColor.withValues(alpha: .6),
                            primaryColor.withValues(alpha: .2),
                          ],
                        ),
                      ),
                      child: Icon(
                        CupertinoIcons.person_solid,
                        size: 140,
                        color: Colors.white.withValues(alpha: .3),
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 160,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              isDark
                                  ? Colors.black.withValues(alpha: .9)
                                  : Colors.black.withValues(alpha: .7),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 24,
                      right: 24,
                      left: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nonNullUser.name,
                            style: const TextStyle(
                              fontFamily: 'CR',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@${nonNullUser.userName}',
                            style: TextStyle(
                              fontFamily: 'CR',
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: .8),
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

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                      child: Text(
                        'اطلاعات کاربر',
                        style: TextStyle(
                          fontFamily: 'CR',
                          fontSize: 14,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: CupertinoColors.activeBlue.withValues(
                                  alpha: .15,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                CupertinoIcons.mail_solid,
                                color: CupertinoColors.activeBlue,
                                size: 22,
                              ),
                            ),
                            title: Text(
                              'ایمیل',
                              style: TextStyle(
                                fontFamily: 'CR',
                                fontSize: 13,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            subtitle: Text(
                              nonNullUser.email,
                              style: TextStyle(
                                fontFamily: 'CR',
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.pushNamed(
                            ChatScreen.routeName,
                            extra: nonNullUser,
                            pathParameters: {'friendId': nonNullUser.id},
                          );
                        },
                        icon: const Icon(
                          CupertinoIcons.chat_bubble_text_fill,
                          color: Colors.black,
                        ),
                        label: const Text(
                          'ارسال پیام',
                          style: TextStyle(
                            fontFamily: 'CR',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
