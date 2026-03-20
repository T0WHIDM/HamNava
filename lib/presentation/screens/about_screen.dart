import 'package:flutter/material.dart';
import 'package:flutter_chat_room_app/core/utility/url_luncher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();

  static String get routeName => 'AboutScreen';
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'هم‌نوا',
          style: TextStyle(
            fontFamily: 'CR',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),

          _buildLinkItem(
            icon: FontAwesomeIcons.telegram,
            title: 'تلکرام',
            onTap: () => MyUrlLuncher.launchLink('https://t.me/T0WHID'),
          ),
          _buildLinkItem(
            icon: FontAwesomeIcons.github,
            title: 'سورس کد',
            onTap: () => MyUrlLuncher.launchLink('https://github.com/T0WHIDM'),
          ),
          _buildLinkItem(
            icon: Icons.email,
            title: 'ایمیل',
            onTap: () =>
                MyUrlLuncher.launchLink('mailto:towhidmgholami@gmail.com'),
          ),

          const Spacer(),

          const Padding(
            padding: EdgeInsets.only(bottom: 32),
            child: Text(
              'v 1.0.0',
              style: TextStyle(
                fontFamily: 'GB',
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                Icon(icon, size: 24, color: Colors.black87),
                const SizedBox(width: 20),
                Text(
                  title,
                  style: const TextStyle(fontFamily: 'cr', fontSize: 16),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
