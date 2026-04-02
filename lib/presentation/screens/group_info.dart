import 'package:flutter/material.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
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
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: primaryColor,
                        child: const Icon(
                          Icons.groups_rounded,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15), // فاصله برای قرارگیری نام گروه
                ],
              ),
            ),
          ),

          // فاصله بین هدر و لیست اعضا
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // 2. عنوان بخش اعضا
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 8.0,
              ),
              child: Text(
                'اعضای گروه (${conversation.participants.length})',
                style: TextStyle(
                  fontFamily: 'cr',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ),
          ),

          // 3. کارت لیست اعضا (Inset-Grouped)
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
                child: Column(
                  children: [
                    // دکمه افزودن عضو
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // TODO: پیاده‌سازی افزودن عضو
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
                                  color: primaryColor.withValues(alpha: 0.15),
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
                            ],
                          ),
                        ),
                      ),
                    ),
                    Divider(height: 1, indent: 70, color: dividerColor),

                    // رندر لیست اعضا
                    ...List.generate(conversation.participants.length, (index) {
                      final user = conversation.participants[index];
                      final isAdmin = conversation.admin.any(
                        (admin) => admin.id == user.id,
                      );
                      final isLast =
                          index == conversation.participants.length - 1;

                      return Column(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // TODO: مشاهده پروفایل شخص
                              },
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
                                              fontWeight: FontWeight.w500,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            isAdmin ? 'مدیر گروه' : 'عضو',
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
                                      Icon(
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
                            Divider(height: 1, indent: 70, color: dividerColor),
                        ],
                      );
                    }),
                  ],
                ),
              ),
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

          // فضای خالی پایین صفحه برای جلوگیری از چسبیدن به لبه پایین گوشی
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }
}
