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
      body: Column(
        children: [
          const SizedBox(height: 100),
          Center(
            child: Stack(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 78,
                  child: Icon(
                    FontAwesomeIcons.user,
                    size: 48,
                    color: Colors.black,
                  ),
                ),
                Positioned(
                  left: 105,
                  top: 105,
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: Center(
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(FontAwesomeIcons.pencil, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'towhid',
            style: TextStyle(fontFamily: 'GB', fontSize: 24),
          ),
          const SizedBox(height: 8),
          const Text(
            'towhidmgholami@gmail.com',
            style: TextStyle(
              fontFamily: 'GR',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: 350,
                height: 300,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(30, 0, 0, 0),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.moon),
                          SizedBox(width: 20),
                          Text(
                            'Dark Mode',
                            style: TextStyle(fontFamily: 'GB', fontSize: 16),
                          ),
                          Spacer(),
                          Icon(Icons.arrow_right_sharp, size: 32),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: InkWell(
                        onTap: () {
                          //  await Share.share('share our app with your friends');
                        },
                        child: const Row(
                          children: [
                            Icon(FontAwesomeIcons.shareNodes),
                            SizedBox(width: 20),
                            Text(
                              'share',
                              style: TextStyle(fontFamily: 'GB', fontSize: 16),
                            ),
                            Spacer(),
                            Icon(Icons.arrow_right_sharp, size: 32),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: InkWell(
                        onTap: () {
                          context.pushNamed(AboutScreen.routeName);
                        },
                        child: const Row(
                          children: [
                            Icon(FontAwesomeIcons.solidCircleQuestion),
                            SizedBox(width: 20),
                            Text(
                              'About',
                              style: TextStyle(fontFamily: 'GB', fontSize: 16),
                            ),
                            Spacer(),
                            Icon(Icons.arrow_right_sharp, size: 32),
                          ],
                        ),
                      ),
                    ),
                    BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthSuccess) {
                          state.result.fold(
                            (failure) {
                              return ScaffoldMessenger.of(context).showSnackBar(
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
                              context.read<AuthBloc>().add(AuthLogOutEvent());
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.logout_outlined),
                                SizedBox(width: 20),
                                Text(
                                  'Log out',
                                  style: TextStyle(
                                    fontFamily: 'GB',
                                    fontSize: 16,
                                  ),
                                ),
                                Spacer(),
                                Icon(Icons.arrow_right_sharp, size: 32),
                              ],
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
        ],
      ),
    );
  }
}
