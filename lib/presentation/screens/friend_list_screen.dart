import 'package:flutter/cupertino.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF0ED0D3);

    // رنگ‌های استایل iOS/Premium
    final scaffoldBg = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
    final dividerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: RefreshIndicator(
        color: primaryColor,
        backgroundColor: cardColor,
        onRefresh: () async {
          final userId = locator<PocketBase>().authStore.record!.id;
          context.read<UserBloc>().add(FriendListEvent(userId));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            // 1. هدر صفحه
            SliverAppBar(
              expandedHeight: 60,
              pinned: true,
              backgroundColor: scaffoldBg,
              surfaceTintColor: Colors.transparent,
              title: const Text(
                'دوستان من',
                style: TextStyle(
                  fontFamily: 'CR',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
      
            // 2. بدنه صفحه (مدیریت State ها)
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is FriendsListLoadingState) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CupertinoActivityIndicator(radius: 16),
                    ),
                  );
                }
      
                if (state is FriendListSuccessState) {
                  return state.result.fold(
                    (failure) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            failure.message,
                            style: const TextStyle(fontFamily: 'CR', color: Colors.redAccent),
                          ),
                        ),
                      );
                    },
                    (success) {
                      if (success.isEmpty) {
                        return _buildEmptyState(isDark);
                      }
      
                      // 3. لیست Inset-Grouped (طراحی مدرن)
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isDark ? [] : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: success.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  indent: 80, // شروع خط از بعد از آواتار
                                  endIndent: 16,
                                  color: dividerColor,
                                ),
                                itemBuilder: (context, index) {
                                  final friend = success[index];
                                  return _buildFriendRow(context, friend, isDark, primaryColor);
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
      
                return _buildEmptyState(isDark);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ویجت ردیف هر دوست
  Widget _buildFriendRow(BuildContext context, UserEntity friend, bool isDark, Color primaryColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.pushNamed(UserProfileScreen.routeName, extra: friend);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // آواتار
              CircleAvatar(
                radius: 26,
                backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                // backgroundImage: friend.avatar != null ? NetworkImage(...) : null,
                child: Icon(
                  CupertinoIcons.person_fill,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              
              // اطلاعات کاربر
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.name,
                      style: TextStyle(
                        fontFamily: 'CR',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${friend.userName}',
                      style: TextStyle(
                        fontFamily: 'CR',
                        fontSize: 13,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // دکمه شروع چت (شیک و کپسولی)
              GestureDetector(
                onTap: () {
                  context.pushNamed(
                    ChatScreen.routeName,
                    pathParameters: {'friendId': friend.id},
                    extra: friend,
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      CupertinoIcons.chat_bubble_text_fill,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ویجت حالت خالی (وقتی دوستی وجود ندارد)
  Widget _buildEmptyState(bool isDark) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: isDark ? [] : [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Icon(
                CupertinoIcons.person_2_fill,
                size: 64,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لیست دوستان خالی است',
              style: TextStyle(
                fontFamily: 'CR',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'شما هنوز هیچ دوستی اضافه نکرده‌اید',
              style: TextStyle(
                fontFamily: 'CR',
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 40), // برای ایجاد تعادل در وسط صفحه
          ],
        ),
      ),
    );
  }
}
