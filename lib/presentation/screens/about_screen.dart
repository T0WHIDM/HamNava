import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_room_app/core/utility/url_luncher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static String get routeName => 'AboutScreen';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // پالت رنگی مدرن
    final scaffoldBg = isDark ? Colors.black : const Color(0xFFF2F2F7);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final primaryColor = const Color(0xFF0ED0D3);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: scaffoldBg,
        elevation: 0,
        title: const Text(
          'درباره ما',
          style: TextStyle(fontFamily: 'CR', fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            const SizedBox(height: 32),

            // هدر: لوگو و نام اپلیکیشن
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Icon(
                    CupertinoIcons.chat_bubble_2_fill,
                    size: 45,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'هم‌نوا',
              style: TextStyle(fontFamily: 'CR', fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'پیام‌رسان مدرن و امن',
              style: TextStyle(fontFamily: 'CR', fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 40),

            // لیست Inset-Grouped لینک‌های ارتباطی
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                clipBehavior: Clip.antiAlias, // برای گرد ماندن گوشه‌ها هنگام کلیک
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildLinkItem(
                      context: context,
                      icon: FontAwesomeIcons.telegram,
                      iconColor: Colors.blue,
                      title: 'تلگرام',
                      onTap: () => MyUrlLuncher.launchLink('https://t.me/T0WHID'),
                    ),
                    Divider(height: 1, thickness: 0.5, color: Colors.grey.withOpacity(0.2), indent: 56),
                    _buildLinkItem(
                      context: context,
                      icon: FontAwesomeIcons.github,
                      iconColor: isDark ? Colors.white : Colors.black,
                      iconBgColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      title: 'سورس کد',
                      onTap: () => MyUrlLuncher.launchLink('https://github.com/T0WHIDM'),
                    ),
                    Divider(height: 1, thickness: 0.5, color: Colors.grey.withOpacity(0.2), indent: 56),
                    _buildLinkItem(
                      context: context,
                      icon: CupertinoIcons.mail_solid,
                      iconColor: CupertinoColors.activeOrange,
                      title: 'ایمیل',
                      onTap: () => MyUrlLuncher.launchLink('mailto:towhidmgholami@gmail.com'),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // ورژن اپلیکیشن
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Text(
                'نسخه 1.0.0',
                style: TextStyle(
                  fontFamily: 'GB',
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ویجت سازنده آیتم‌های لیست
  Widget _buildLinkItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    Color? iconBgColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              // باکس رنگی آیکون
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconBgColor ?? iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(fontFamily: 'CR', fontSize: 16),
              ),
              const Spacer(),
              // آیکون فلش (چون صفحه RTL است، فلش رو به جلو باید سمت چپ باشد)
              Icon(
                CupertinoIcons.chevron_left,
                size: 18,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
