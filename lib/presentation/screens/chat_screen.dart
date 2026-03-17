import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();

  static String get routeName => 'ChatScreen';
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
              child: const Icon(FontAwesomeIcons.user),
            ),
            const SizedBox(width: 30),
            const Text(
              'towhid',
              style: TextStyle(fontFamily: 'GB', fontSize: 20),
            ),
            const Spacer(),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 120,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 20,
                  ),
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 40,
            right: 0,
            top: 80,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 20,
                  ),
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 120,
            top: 160,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 20,
                  ),
                  height: 250,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 40,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(30, 0, 0, 0),
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hint: Text(
                              'message',
                              style: TextStyle(
                                fontFamily: 'gb',
                                color: Color.fromARGB(255, 130, 130, 130),
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(32),
                              ),
                              borderSide: BorderSide.none,
                              gapPadding: 22,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.attach_file),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 35,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.send),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
