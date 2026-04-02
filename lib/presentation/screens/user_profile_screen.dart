import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';
import 'package:flutter_chat_room_app/presentation/screens/chat_screen.dart';
import 'package:go_router/go_router.dart';

class UserProfileScreen extends StatelessWidget {
  // ۱. ایمن‌سازی state.extra با قرار دادن نوع داده به صورت Nullable
  final UserEntity? user;

  const UserProfileScreen(this.user, {super.key});

  static String get routeName => 'UserProfileScreen';

  @override
  Widget build(BuildContext context) {
    // ۲. مدیریت حالت Null برای جلوگیری از خطای type cast هنگام رفرش شدن روتر
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/'); // هدایت به صفحه اصلی در صورت نبود تاریخچه
        }
      });
      return const Scaffold(
        body: Center(child: CupertinoActivityIndicator()),
      );
    }

    final nonNullUser = user!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // پالت رنگی مدرن (Inset-Grouped)
    final scaffoldBg = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final primaryColor = const Color(0xFF0ED0D3);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // هدر داینامیک و مدرن
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
                    backgroundColor: Colors.black.withOpacity(0.4),
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
                    // پس‌زمینه آواتار/کاور
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primaryColor.withOpacity(0.6),
                            primaryColor.withOpacity(0.2),
                          ],
                        ),
                      ),
                      child: Icon(
                        CupertinoIcons.person_solid,
                        size: 140,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    
                    // گرادینت تیره پایین هدر برای خوانایی بهتر متن
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
                                  ? Colors.black.withOpacity(0.9)
                                  : Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // نام و یوزرنیم
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
                              fontFamily: 'CR', // یا GB در صورت نیاز
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
                              color: Colors.white.withOpacity(0.8),
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

            // محتوای صفحه
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عنوان بخش
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

                    // کارت Inset-Grouped اطلاعات
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: CupertinoColors.activeBlue.withOpacity(0.15),
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
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            subtitle: Text(
                              nonNullUser.email,
                              style: TextStyle(
                                fontFamily: 'CR', // یا GB برای وزن بیشتر
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

                    // دکمه پریمیوم ارسال پیام
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
