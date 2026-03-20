import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_state.dart';
import 'package:flutter_chat_room_app/presentation/screens/about_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/login_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();

  static String get routeName => 'SettingScreen';
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 100),
            const Center(
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 64,
                child: Icon(
                  FontAwesomeIcons.user,
                  size: 48,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'towhid',
              style: TextStyle(fontFamily: 'GB', fontSize: 24),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: InkWell(
                        radius: 27,
                        onTap: () {},
                        child: Container(
                          width: 165,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .05),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(16),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit),
                              SizedBox(height: 5),
                              Text(
                                'ویرایش اطلاعات',
                                style: TextStyle(fontFamily: 'CR'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: InkWell(
                        radius: 27,
                        onTap: () {},
                        child: Container(
                          width: 165,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .05),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(16),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_camera),
                              SizedBox(height: 5),
                              Text(
                                'افزودن عکس',
                                style: TextStyle(fontFamily: 'CR'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .05),
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Column(
                      children: [
                        _buildSettingItem(
                          icon: FontAwesomeIcons.moon,
                          title: 'دارک مود',
                          onTap: () {},
                        ),
                        _buildSettingItem(
                          icon: FontAwesomeIcons.shareNodes,
                          title: 'اشتراک گداری',
                          onTap: () {
                            // Share.share('Check out this app!');
                          },
                        ),
                        _buildSettingItem(
                          icon: FontAwesomeIcons.solidCircleQuestion,
                          title: 'درباره ما',
                          onTap: () => context.pushNamed(AboutScreen.routeName),
                        ),

                        BlocConsumer<AuthBloc, AuthState>(
                          listener: (context, state) {
                            if (state is AuthSuccess) {
                              state.result.fold(
                                (failure) {
                                  return ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                        textDirection: TextDirection.rtl,
                                        failure.message,
                                        style: const TextStyle(
                                          fontFamily: 'CR',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                (success) {
                                  context.goNamed(LoginScreen.namedRoute);
                                },
                              );
                            }
                          },
                          builder: (context, state) {
                            if (state is AuthLoading) {
                              return const SpinKitFoldingCube(
                                color: Color.fromARGB(255, 14, 208, 211),
                                size: 32,
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: InkWell(
                                onTap: () {
                                  context.read<AuthBloc>().add(
                                    AuthLogOutEvent(),
                                  );
                                },
                                child: const Directionality(
                                  textDirection: TextDirection.rtl,

                                  child: Row(
                                    children: [
                                      Icon(Icons.logout_outlined),
                                      SizedBox(width: 20),
                                      Text(
                                        'خروج از حساب کاربری',
                                        style: TextStyle(
                                          fontFamily: 'CR',
                                          fontSize: 16,
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(
                                        Icons.arrow_right_sharp,
                                        size: 32,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildSettingItem({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  bool isLast = false,
}) {
  return InkWell(
    onTap: onTap,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 20),
                Text(
                  title,
                  style: const TextStyle(fontFamily: 'CR', fontSize: 16),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_right_sharp,
                  size: 32,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        if (!isLast) const Divider(height: 3, indent: 60),
      ],
    ),
  );
}
