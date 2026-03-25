import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyBootomNavigationBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MyBootomNavigationBar({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomNavigationBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (int index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              fixedColor: isDark
                  ? const Color.fromARGB(255, 14, 208, 211)
                  : Colors.black,
              unselectedItemColor: isDark ? Colors.white54 : Colors.black54,
              elevation: 0,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              selectedFontSize: 14,
              iconSize: 24,
              unselectedFontSize: 10,
              selectedLabelStyle: const TextStyle(fontFamily: 'CR'),
              unselectedLabelStyle: const TextStyle(fontFamily: 'CR'),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'چت ها'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'دوستان',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'تنظیمات',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
