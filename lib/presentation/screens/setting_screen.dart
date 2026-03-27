import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_state.dart';
import 'package:flutter_chat_room_app/presentation/bloc/theme/theme_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/theme/theme_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_state.dart';
import 'package:flutter_chat_room_app/presentation/screens/about_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/edit_profile_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/login_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();

  static String get routeName => 'SettingScreen';
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.05);

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 100),
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is ProfileInfoLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 14, 208, 211),
                    ),
                  );
                }

                if (state is ProfileInfoSuccessState) {
                  return state.user.fold(
                    (failure) {
                      return Center(
                        child: Text(
                          failure.message,
                          style: const TextStyle(
                            fontFamily: 'CR',
                            color: Colors.red,
                          ),
                        ),
                      );
                    },
                    (success) {
                      final user = success;

                      return Column(
                        children: [
                          Center(
                            child: CircleAvatar(
                              backgroundColor: isDark
                                  ? Colors.grey[800]
                                  : Colors.grey[300],
                              radius: 64,
                              // backgroundImage: user.avatar != null ? NetworkImage(...) : null,
                              child: Icon(
                                FontAwesomeIcons.user,
                                size: 48,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontFamily: 'cr',
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '@${user.userName}',
                            style: const TextStyle(
                              fontFamily: 'cr',
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: InkWell(
                                      radius: 27,
                                      onTap: () async {
                                        await context.pushNamed(
                                          EditProfileScreen.routeNmae,
                                          extra: user,
                                        );

                                        if (context.mounted) {
                                          context.read<UserBloc>().add(
                                            ProfileInfoEvent(user.id),
                                          );
                                        }
                                      },
                                      child: Container(
                                        width: 155,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: containerColor,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(16),
                                          ),
                                        ),
                                        child: const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.edit),
                                            SizedBox(height: 5),
                                            Text(
                                              'ویرایش اطلاعات',
                                              style: TextStyle(
                                                fontFamily: 'CR',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: InkWell(
                                      radius: 27,
                                      onTap: () {},
                                      child: Container(
                                        width: 155,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: containerColor,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(16),
                                          ),
                                        ),
                                        child: const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.photo_camera),
                                            SizedBox(height: 5),
                                            Text(
                                              'افزودن عکس',
                                              style: TextStyle(
                                                fontFamily: 'CR',
                                              ),
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
                        ],
                      );
                    },
                  );
                }

                return const SizedBox(height: 140);
              },
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
                      color: containerColor,
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 16.0,
                            top: 16,
                            bottom: 16,
                          ),
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Row(
                              children: [
                                Icon(
                                  isDark
                                      ? Icons.light_mode_outlined
                                      : Icons.dark_mode_outlined,
                                  size: 24,
                                  color: isDark
                                      ? const Color.fromARGB(255, 235, 177, 2)
                                      : Colors.black,
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  isDark ? 'لایت مود' : 'دارک مود',
                                  style: const TextStyle(
                                    fontFamily: 'CR',
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Transform.scale(
                                  scale: 0.6,
                                  child: SizedBox(
                                    child: Switch(
                                      activeThumbColor: const Color.fromARGB(
                                        255,
                                        14,
                                        208,
                                        211,
                                      ),
                                      value: isDark,
                                      onChanged: (value) {
                                        context.read<ThemeBloc>().add(
                                          ToggleThemeEvent(),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 3, indent: 60),
                        _buildSettingItem(
                          icon: FontAwesomeIcons.shareNodes,
                          title: 'اشتراک گذاری',
                          onTap: () {
                            SharePlus.instance.share(
                              ShareParams(
                                text: 'share our app with your friends',
                              ),
                            );
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
    radius: 0,
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
