import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomSwitchWidget extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onChanged;

  const CustomSwitchWidget({
    super.key,
    required this.isDarkMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isDarkMode),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutBack,
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isDarkMode ? const Color(0xFF0ED0D3) : const Color(0xFFE5E5EA),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? const Color(0xFF0ED0D3).withValues(alpha: .3)
                  : Colors.transparent,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutBack,
          alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) => RotationTransition(
                    turns: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: Icon(
                    isDarkMode
                        ? CupertinoIcons.moon_stars_fill
                        : CupertinoIcons.sun_max_fill,
                    key: ValueKey<bool>(isDarkMode),
                    size: 16,
                    color: isDarkMode
                        ? const Color(0xFF0ED0D3)
                        : const Color(0xFFFF9500),
                    shadows: const [],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
