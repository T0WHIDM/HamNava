import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_state.dart';
import 'package:flutter_chat_room_app/presentation/customWidget/chat_list_item.dart';
import 'package:flutter_chat_room_app/presentation/screens/create_group_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/group_chat_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/user_search_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static String get namedRoute => 'HomeScreen';
}

class _HomeScreenState extends State<HomeScreen> {
  FocusNode searchFocusNode = FocusNode();
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchFocusNode.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF0ED0D3);

    // رنگ‌های استایل iOS/Premium
    final scaffoldBg = isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final searchBgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: RefreshIndicator(
          color: primaryColor,
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          onRefresh: () async {
            final userId = locator<PocketBase>().authStore.record!.id;
            context.read<ChatBloc>().add(GetChatListEvent(userId));
            await Future.delayed(const Duration(seconds: 1));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // 1. هدر صفحه (AppBar) مدرن
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: scaffoldBg,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'هم نوا',
                  style: TextStyle(
                    fontFamily: 'CR',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                
                leading: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: IconButton(
                    onPressed: () {
                      context.pushNamed(UserSearchScreen.routeName);
                    },
                    icon: Icon(
                      CupertinoIcons.square_pencil, // آیکون مدرن ایجاد چت
                      color: isDark ? Colors.white : Colors.black87,
                      size: 24,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () async {
                      final result = await context.pushNamed(
                        CreateGroupScreen.routeName,
                      );

                      if (result != null && result is ConversationEntity) {
                        if (context.mounted) {
                          final userId = locator<PocketBase>().authStore.record!.id;
                          context.read<ChatBloc>().add(GetChatListEvent(userId));
                          context.pushNamed(GroupChatScreen.routeName, extra: result);
                        }
                      }
                    },
                    icon: Icon(
                      CupertinoIcons.person_2, // آیکون مدرن ایجاد گروه
                      color: isDark ? Colors.white : Colors.black87,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),

              // 2. نوار جستجوی اختصاصی (iOS Style)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: searchBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(
                            CupertinoIcons.search,
                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: searchFocusNode,
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                              style: TextStyle(
                                fontFamily: 'CR',
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: 'جستجو در گفتگوها...',
                                hintStyle: TextStyle(
                                  fontFamily: 'CR',
                                  fontSize: 15,
                                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                          // دکمه پاک کردن متن جستجو
                          if (searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  searchQuery = '';
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Icon(
                                  CupertinoIcons.clear_thick_circled,
                                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                                  size: 18,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 3. بدنه صفحه و لیست گفتگوها
              BlocBuilder<ChatBloc, ChatState>(
                buildWhen: (previous, current) {
                  return current is ChatLoadingState || current is ChatListSUccessState;
                },
                builder: (context, state) {
                  if (state is ChatLoadingState) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CupertinoActivityIndicator(radius: 16),
                      ),
                    );
                  }

                  if (state is ChatListSUccessState) {
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
                        final filteredList = success.where((chat) {
                          if (searchQuery.isEmpty) return true;

                          final String rawChatName = chat.isGroup
                              ? (chat.name ?? 'گروه')
                              : (chat.participants.isNotEmpty ? chat.participants.last.name : 'کاربر');

                          final searchLower = searchQuery.toLowerCase();
                          return rawChatName.toLowerCase().contains(searchLower);
                        }).toList();

                        if (filteredList.isEmpty) {
                          return _buildEmptyState(context, isDark, isSearchEmpty: searchQuery.isNotEmpty);
                        }

                        // نمایش لیست چت‌ها از فایل جداگانه (ChatListItem یک Sliver است)
                        return ChatListItem(filteredList);
                      },
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
              const SliverPadding(padding: EdgeInsetsGeometry.only(top: 120)),
            ],
          ),
        ),
      ),
    );
  }

  // 4. حالت خالی مدرن (وقتی چتی نیست یا جستجو نتیجه ندارد)
  Widget _buildEmptyState(BuildContext context, bool isDark, {bool isSearchEmpty = false}) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearchEmpty ? CupertinoIcons.search : CupertinoIcons.chat_bubble_2_fill,
                size: 64,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearchEmpty ? 'گفتگویی پیدا نشد' : 'شما هنوز گفتگویی ندارید',
              style: TextStyle(
                fontFamily: 'CR',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearchEmpty ? 'نام دیگری را امتحان کنید' : 'از بالا سمت چپ گفتگو را آغاز کنید',
              style: TextStyle(
                fontFamily: 'CR',
                fontSize: 14,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
