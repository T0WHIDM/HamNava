import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_chat_room_app/presentation/customWidget/chat_list_item.dart';
import 'package:flutter_chat_room_app/presentation/screens/create_group_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/user_search_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static String get namedRoute => 'HomeScreen';
}

class _HomeScreenState extends State<HomeScreen> {
  FocusNode searchFocusNode = FocusNode();

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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
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
                        color: Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextField(
                          onChanged: (value) {
                            if (value.isNotEmpty) {}
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
            const ChatListItem(),
            const SliverPadding(padding: EdgeInsetsGeometry.only(top: 120)),
          ],
        ),
      ),
    );
  }
}
