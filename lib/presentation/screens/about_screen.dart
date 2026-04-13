import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_room_app/constants/color.dart';
import 'package:flutter_chat_room_app/core/utility/url_luncher.dart';
import 'package:flutter_chat_room_app/presentation/customWidget/custom_snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static String get routeName => 'AboutScreen';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          style: TextStyle(
            fontFamily: 'CR',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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

            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: .15),
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
              style: TextStyle(
                fontFamily: 'CR',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '''           هم نوا پیام رسانی مدرن و متن باز است  
               و برای کاربرانی طراحی شده است که امکان 
                دسترسی به اینترنت بین الملل را ندارند''',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'CR',
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                clipBehavior: Clip.antiAlias,
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
                      onTap: () =>
                          MyUrlLuncher.launchLink('https://t.me/HamNavaApp'),
                    ),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Colors.grey.withValues(alpha: .2),
                      indent: 56,
                    ),
                    _buildLinkItem(
                      context: context,
                      icon: FontAwesomeIcons.github,
                      iconColor: isDark ? Colors.white : Colors.black,
                      iconBgColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      title: 'سورس کد',
                      onTap: () => MyUrlLuncher.launchLink(
                        'https://github.com/Lilfibonacci/HamNava',
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Colors.grey.withValues(alpha: .2),
                      indent: 56,
                    ),
                    _buildLinkItem(
                      context: context,
                      icon: CupertinoIcons.mail_solid,
                      iconColor: CupertinoColors.activeOrange,
                      title: 'ایمیل',
                      onTap: () => MyUrlLuncher.launchLink(
                        'mailto:lilfibonacci1@gmail.com',
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Colors.grey.withValues(alpha: .2),
                      indent: 56,
                    ),
                    _buildLinkItem(
                      context: context,
                      icon: CupertinoIcons.money_dollar_circle_fill,
                      iconColor: CupertinoColors.activeGreen,
                      title: 'حمایت از ما',
                      onTap: () => _showSupportSheet(context),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            const Padding(
              padding: EdgeInsets.only(bottom: 32),
              child: Column(
                children: [
                  Text(
                    'Designed with ♥️ by Lil fibonacci',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'CR'),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'v 1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'CR',
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconBgColor ?? iconColor.withValues(alpha: .15),
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

  void _showSupportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: .3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  '❤️ حمایت از ما ',
                  style: TextStyle(
                    fontFamily: 'CR',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                _walletTile(
                  context,
                  title: 'USDT (TRC20)',
                  address: 'TANUgkm65exhiaTReJnZ7xxAbukHXDEZ8R',
                ),

                _walletTile(
                  context,
                  title: 'TON',
                  address: 'UQDdPFb3le5Tx8rkvSbiVigxqARKF3NDVrzDjCKPfexqTUFa',
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _walletTile(
    BuildContext context, {
    required String title,
    required String address,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontFamily: 'CR')),
      subtitle: Text(
        address,
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.copy),
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: address));

          if (!context.mounted) return;

          context.pop();

          final snackBar = buildCustomSnackBar(
            color: CustomColor.green,
            message: 'آدرس با موفقیت کپی شد',
            title: title,
            type: ContentType.success,
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        },
      ),
    );
  }
}
