import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyBootomNavigationBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MyBootomNavigationBar({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: BottomNavigationBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (int index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              fixedColor: Colors.black,
              elevation: 0,
              backgroundColor: const Color.fromARGB(30, 0, 0, 0),
              selectedFontSize: 18,
              iconSize: 24,
              unselectedFontSize: 12,
              selectedLabelStyle: const TextStyle(fontFamily: 'GR'),
              unselectedLabelStyle: const TextStyle(fontFamily: 'GR'),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'chats'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'setting',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
