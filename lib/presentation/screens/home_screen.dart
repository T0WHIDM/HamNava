import 'package:flutter/material.dart';
import 'package:flutter_chat_room_app/presentation/customWidget/chat_list_item.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
              title: const Text(
                'مسیجیفای',
                style: TextStyle(fontFamily: 'CR', fontSize: 24),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(FontAwesomeIcons.plus, size: 24),
                ),
                const SizedBox(width: 15),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 10,
                ),
                child: TextField(
                  focusNode: searchFocusNode,
                  cursorColor: Colors.black,
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    label: Text(
                      'search',
                      style: TextStyle(
                        fontFamily: 'GB',
                        fontSize: 16,
                        color: Color.fromARGB(191, 119, 119, 119),
                        fontWeight: FontWeight.bold
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
