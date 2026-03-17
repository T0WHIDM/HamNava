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
        title: const Text(
          'مسیجیفای',
          style: TextStyle(fontFamily: 'CR', fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 44.0,
                vertical: 22.0,
              ),
              child: InkWell(
                onTap: () {
                  MyUrlLuncher.launchLink('https://t.me/T0WHID');
                },
                child: const Row(
                  children: [
                    Icon(FontAwesomeIcons.telegram),
                    SizedBox(width: 20),
                    Text(
                      'telegram',
                      style: TextStyle(fontFamily: 'GB', fontSize: 16),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_right_sharp, size: 32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 44.0,
                vertical: 22.0,
              ),
              child: InkWell(
                onTap: () {
                  MyUrlLuncher.launchLink('https://github.com/T0WHIDM');
                },
                child: const Row(
                  children: [
                    Icon(FontAwesomeIcons.github),
                    SizedBox(width: 20),
                    Text(
                      'source code',
                      style: TextStyle(fontFamily: 'GB', fontSize: 16),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_right_sharp, size: 32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 44.0,
                vertical: 22.0,
              ),
              child: InkWell(
                onTap: () {
                  MyUrlLuncher.launchLink('mailto:towhidmgholami@gmail.com');
                },
                child: const Row(
                  children: [
                    Icon(Icons.email),
                    SizedBox(width: 20),
                    Text(
                      'email',
                      style: TextStyle(fontFamily: 'GB', fontSize: 16),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_right_sharp, size: 32),
                  ],
                ),
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsetsGeometry.only(bottom: 32),
              child: Text(
                'v 1.0.0',
                style: TextStyle(fontFamily: 'GB', fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
