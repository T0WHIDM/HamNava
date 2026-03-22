import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_chat_room_app/presentation/screens/home_screen.dart';
import 'package:go_router/go_router.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  static String get routeName => 'UserSearchScreen';

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: IconButton(
            onPressed: () {
              context.goNamed(HomeScreen.namedRoute);
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
        ),
        title: const Text(
          'جستجوی دوستان',
          style: TextStyle(fontFamily: 'CR', color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
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
                      controller: _searchController,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          // context.read<UserBloc>().add(SearchUserEvent(value));
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'آی‌دی کاربر را وارد کنید...',
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
          buildEmptyState(),
        ],
      ),
    );
  }

  Widget buildUserList(List<dynamic> users) {
    if (users.isEmpty) {
      return const Center(
        child: Text(
          'کاربری با این مشخصات پیدا نشد.',
          style: TextStyle(fontFamily: 'cr'),
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          elevation: 0,
          color: Colors.grey[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              user.username,
              style: const TextStyle(fontFamily: 'GB'),
            ),
            subtitle: Text(
              user.email,
              style: const TextStyle(fontFamily: 'cr', fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }

  Widget buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(fontFamily: 'GR', color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Icon(Icons.person_search, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'نام کاربری دوست خود را جستجو کنید',
            style: TextStyle(fontFamily: 'CR', color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
