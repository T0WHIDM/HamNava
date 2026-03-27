import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_state.dart';
import 'package:flutter_chat_room_app/presentation/customWidget/chat_list_item.dart';
import 'package:flutter_chat_room_app/presentation/screens/create_group_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/user_search_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: RefreshIndicator(
          color: const Color.fromARGB(255, 14, 208, 211),
          onRefresh: () async {
            final userId = locator<PocketBase>().authStore.record!.id;
            context.read<ChatBloc>().add(GetChatListEvent(userId));
            await Future.delayed(const Duration(seconds: 1));
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                title: const Text(
                  'هم نوا',
                  style: TextStyle(fontFamily: 'CR', fontSize: 24),
                ),
                centerTitle: true,
                leading: IconButton(
                  onPressed: () {
                    context.pushNamed(UserSearchScreen.routeName);
                  },
                  icon: const Icon(Icons.add, size: 32),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      context.pushNamed(CreateGroupScreen.routeName);
                    },
                    icon: const Icon(FontAwesomeIcons.userGroup, size: 20),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'جستجو در گفتگو ها ...',
                              hintStyle: const TextStyle(
                                fontFamily: 'CR',
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoadingState) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 14, 208, 211),
                        ),
                      ),
                    );
                  }

                  if (state is ChatListSUccessState) {
                    return state.result.fold(
                      (failure) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Text(
                              failure.message,
                              style: const TextStyle(fontFamily: 'cr'),
                            ),
                          ),
                        );
                      },
                      (success) {
                        final filteredList = success.where((chat) {
                          if (searchQuery.isEmpty) {
                            return true;
                          }

                          final chatName = (chat.participants.last.name)
                              .toLowerCase();
                          final searchLower = searchQuery.toLowerCase();

                          return chatName.contains(searchLower);
                        }).toList();

                        if (filteredList.isEmpty) {
                          return SliverFillRemaining(
                            child: _buildEmptyState(
                              context,
                              isSearchEmpty: searchQuery.isNotEmpty,
                            ),
                          );
                        }

                        return ChatListItem(filteredList);
                      },
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              const SliverPadding(padding: EdgeInsets.only(top: 120)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {bool isSearchEmpty = false}) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearchEmpty ? Icons.search_off : Icons.chat_bubble_outline,
              size: 80,
              color: isSearchEmpty ? Colors.redAccent : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isSearchEmpty
                  ? 'گفتگویی با این نام پیدا نشد'
                  : 'شما هنوز گفتگویی ندارید',
              style: TextStyle(
                fontFamily: 'CR',
                color: isSearchEmpty ? Colors.redAccent : Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
