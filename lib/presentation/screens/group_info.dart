import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_state.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_state.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';

class GroupInfoScreen extends StatelessWidget {
  final ConversationEntity conversation;

  const GroupInfoScreen({super.key, required this.conversation});

  static String get routeName => 'GroupInfoScreen';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF0ED0D3);

    final scaffoldBg = isDark
        ? const Color(0xFF000000)
        : const Color(0xFFF2F2F7);
    final cardColor = isDark
        ? const Color(0xFF1C1C1E)
        : const Color(0xFFFFFFFF);
    final dividerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            expandedHeight: 260.0,
            pinned: true,
            stretch: true,
            backgroundColor: cardColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: Text(
                conversation.name ?? 'گروه بدون نام',
                style: TextStyle(
                  fontFamily: 'cr',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              background: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // آواتار گروه
                  Hero(
                    tag: 'group_avatar_${conversation.id}',
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.2),
                            blurRadius: 25,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: primaryColor,
                        child: Icon(
                          Icons.groups_rounded,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // بخش هدر (تعداد اعضا) و کارت لیست اعضا به صورت یکپارچه درون BlocConsumer
          SliverToBoxAdapter(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is AddFriendToGroupSuccessState) {
                  // چون خروجی شما Either است، در لیسنر هم باید موفقیت یا خطا را چک کنیم
                  state.result.fold(
                    (failure) {
                      // اگر با وجود استیت Success، نتیجه دیتابیس خطا بود (Left)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            failure.message, // نمایش پیام خطای سرور
                            style: const TextStyle(
                              fontFamily: 'cr',
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    (success) {
                      // اگر واقعا موفقیت آمیز بود (Right)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'کاربر با موفقیت به گروه اضافه شد',
                            style: TextStyle(
                              fontFamily: 'cr',
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  );
                }
              },
              builder: (context, state) {
                // 1. لیست پیش‌فرض اعضا از آبجکت اولیه گروه
                var currentParticipants = conversation.participants;

                // 2. اگر استیت جدید دریافت شد، فقط لیست را آپدیت می‌کنیم (return نمی‌کنیم)
                if (state is AddFriendToGroupSuccessState) {
                  state.result.fold(
                    (failure) {
                      // در صورت خطا کاری نمی‌کنیم تا همان لیست قبلی نشان داده شود
                      // (خطا در لیسنر بالا با اسنک‌بار نشان داده می‌شود)
                    },
                    (success) {
                      // در صورت موفقیت، متغیر لیست را آپدیت می‌کنیم
                      currentParticipants = success.participants;
                    },
                  );
                }

                // 3. حالا UI را رندر می‌کنیم
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عنوان بخش اعضا (تعداد اعضا آپدیت می‌شود)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        'اعضای گروه (${currentParticipants.length})',
                        style: TextStyle(
                          fontFamily: 'cr',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),

                    // کارت لیست اعضا (Inset-Grouped)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Column(
                          children: [
                            // دکمه افزودن عضو
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  _showAddFriendBottomSheet(
                                    context,
                                    conversation.id,
                                    isDark,
                                    cardColor,
                                  );
                                },
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: primaryColor.withValues(
                                            alpha: 0.15,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          CupertinoIcons.person_add_solid,
                                          color: primaryColor,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Expanded(
                                        child: Text(
                                          'افزودن عضو جدید',
                                          style: TextStyle(
                                            fontFamily: 'cr',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: primaryColor,
                                          ),
                                        ),
                                      ),
                                      // نمایش لودینگ هنگام اضافه کردن کاربر
                                      if (state is ChatLoadingState)
                                        const CupertinoActivityIndicator(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Divider(height: 1, indent: 70, color: dividerColor),

                            // رندر لیست اعضا با متغیر آپدیت شده (currentParticipants)
                            ...List.generate(currentParticipants.length, (
                              index,
                            ) {
                              final user = currentParticipants[index];
                              final isAdmin = conversation.admin.any(
                                (admin) => admin.id == user.id,
                              );
                              final isLast =
                                  index == currentParticipants.length - 1;

                              return Column(
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {},
                                      borderRadius: isLast
                                          ? const BorderRadius.vertical(
                                              bottom: Radius.circular(20),
                                            )
                                          : BorderRadius.zero,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 21,
                                              backgroundColor: isDark
                                                  ? Colors.grey.shade800
                                                  : Colors.grey.shade200,
                                              child: Icon(
                                                CupertinoIcons.person_fill,
                                                color: Colors.grey.shade500,
                                                size: 22,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    user.name,
                                                    style: TextStyle(
                                                      fontFamily: 'cr',
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: isDark
                                                          ? Colors.white
                                                          : Colors.black87,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    isAdmin
                                                        ? 'مدیر گروه'
                                                        : 'عضو',
                                                    style: TextStyle(
                                                      fontFamily: 'cr',
                                                      fontSize: 13,
                                                      color: isAdmin
                                                          ? primaryColor
                                                          : Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (isAdmin)
                                              const Icon(
                                                Icons.verified_rounded,
                                                color: primaryColor,
                                                size: 20,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (!isLast)
                                    Divider(
                                      height: 1,
                                      indent: 70,
                                      color: dividerColor,
                                    ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // 4. کارت تنظیمات خطرناک (ترک گروه)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // TODO: پیاده‌سازی خروج از گروه
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.square_arrow_right,
                            color: Colors.redAccent,
                            size: 24,
                          ),
                          SizedBox(width: 16),
                          Text(
                            'ترک گروه',
                            style: TextStyle(
                              fontFamily: 'cr',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // فضای خالی پایین صفحه
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  void _showAddFriendBottomSheet(
    BuildContext context,
    String chatId,
    bool isDark,
    Color cardColor,
  ) {
    final userBloc = context.read<UserBloc>();
    final chatBloc = context.read<ChatBloc>();

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: userBloc),
            BlocProvider.value(value: chatBloc),
          ],
          child: DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (sheetContext, scrollController) {
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 16),
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Text(
                    'انتخاب مخاطب',
                    style: TextStyle(
                      fontFamily: 'cr',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  Expanded(
                    child: BlocBuilder<UserBloc, UserState>(
                      builder: (context, state) {
                        if (state is FriendsListLoadingState) {
                          return const Center(
                            child: CupertinoActivityIndicator(radius: 16),
                          );
                        }
                        if (state is FriendListSuccessState) {
                          return state.result.fold(
                            (failure) {
                              return Center(
                                child: Text(
                                  failure.message,
                                  style: const TextStyle(
                                    fontFamily: 'cr',
                                    color: Colors.redAccent,
                                  ),
                                ),
                              );
                            },
                            (success) {
                              if (success.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'دوستی یافت نشد.',
                                    style: TextStyle(fontFamily: 'cr'),
                                  ),
                                );
                              }
                              return ListView.builder(
                                controller: scrollController,
                                physics: const BouncingScrollPhysics(),
                                itemCount: success.length,
                                itemBuilder: (context, index) {
                                  final friend = success[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.grey.shade800,
                                      child: Icon(
                                        CupertinoIcons.person,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    title: Text(
                                      friend.name,
                                      style: TextStyle(
                                        fontFamily: 'cr',
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        CupertinoIcons.add_circled_solid,
                                        color: Color(0xFF0ED0D3),
                                      ),
                                      onPressed: () {
                                        // بستن باتم شیت
                                        Navigator.pop(bottomSheetContext);

                                        chatBloc.add(
                                          AddFriendToGroupEvent(
                                           chatId,
                                           friend.id
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
