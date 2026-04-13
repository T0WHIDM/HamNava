import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/constants/color.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_state.dart';
import 'package:flutter_chat_room_app/presentation/bloc/theme/theme_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/theme/theme_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_state.dart';
import 'package:flutter_chat_room_app/presentation/customWidget/custom_snack_bar.dart';
import 'package:flutter_chat_room_app/presentation/customWidget/custom_switch_widget.dart';
import 'package:flutter_chat_room_app/presentation/screens/about_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/edit_profile_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/login_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
    const primaryColor = Color(0xFF0ED0D3);

    final scaffoldBg = isDark
        ? const Color(0xFF000000)
        : const Color(0xFFF2F2F7);
    final cardColor = isDark
        ? const Color(0xFF1C1C1E)
        : const Color(0xFFFFFFFF);
    final dividerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final secondaryTextColor = isDark
        ? Colors.grey.shade400
        : Colors.grey.shade500;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          state.result.fold(
            (failure) {
              final snackBar = buildCustomSnackBar(
                title: 'failure',
                message: failure.message,
                color: CustomColor.red,
                type: .failure,
              );

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(snackBar);
            },
            (success) {
              context.goNamed(LoginScreen.namedRoute);
            },
          );
        }
      },
      child: Scaffold(
        backgroundColor: scaffoldBg,
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                expandedHeight: 60.0,
                pinned: true,
                backgroundColor: scaffoldBg,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: const FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(bottom: 16, right: 24),
                  title: Text(
                    'تنظیمات',
                    style: TextStyle(
                      fontFamily: 'CR',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    if (state is ProfileInfoLoadingState) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Center(
                          child: SpinKitPulsingGrid(
                            color: Color.fromARGB(255, 14, 208, 211),
                            size: 24,
                          ),
                        ),
                      );
                    }

                    if (state is ProfileInfoSuccessState) {
                      return state.user.fold(
                        (failure) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 100),
                            child: Center(
                              child: Text(
                                failure.message,
                                style: const TextStyle(
                                  fontFamily: 'CR',
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          );
                        },
                        (user) {
                          return Column(
                            children: [
                              const SizedBox(height: 20),
                              Hero(
                                tag: 'user_avatar',
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark
                                            ? Colors.black54
                                            : Colors.grey.withValues(
                                                alpha: 0.3,
                                              ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: isDark
                                        ? Colors.grey.shade800
                                        : Colors.white,
                                    radius: 55,
                                    // backgroundImage: user.avatar != null ? NetworkImage(...) : null,
                                    child: Icon(
                                      CupertinoIcons.person_fill,
                                      size: 55,
                                      color: isDark
                                          ? Colors.grey.shade500
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontFamily: 'cr',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '@${user.userName}',
                                style: TextStyle(
                                  fontFamily: 'cr',
                                  fontSize: 15,
                                  color: secondaryTextColor,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // 3. دکمه‌های پروفایل (مدرن و کپسولی)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildProfileButton(
                                        context: context,
                                        title: 'ویرایش اطلاعات',
                                        icon: CupertinoIcons.pencil,
                                        color: primaryColor,
                                        isDark: isDark,
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
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildProfileButton(
                                        context: context,
                                        title: 'تغییر عکس',
                                        icon: CupertinoIcons.camera_fill,
                                        color: Colors.blueAccent,
                                        isDark: isDark,
                                        onTap: () {},
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          );
                        },
                      );
                    }
                    return const SizedBox(height: 140);
                  },
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Column(
                      children: [
                        _buildSettingTile(
                          icon: isDark
                              ? CupertinoIcons.moon_fill
                              : CupertinoIcons.sun_max_fill,
                          iconBgColor: isDark
                              ? Colors.indigoAccent
                              : Colors.orangeAccent,
                          title: 'حالت تاریک (Dark Mode)',
                          trailing: Transform.scale(
                            scale: 0.8,
                            child: CustomSwitchWidget(
                              isDarkMode: isDark,
                              onChanged: (value) {
                                context.read<ThemeBloc>().add(
                                  ToggleThemeEvent(),
                                );
                              },
                            ),
                          ),
                          onTap: () {},
                        ),
                        Divider(height: 1, indent: 60, color: dividerColor),
                        _buildSettingTile(
                          icon: CupertinoIcons.share,
                          iconBgColor: Colors.green,
                          title: 'معرفی به دوستان',
                          onTap: () {
                            SharePlus.instance.share(
                              ShareParams(
                                text:
                                    'بهترین اپلیکیشن چت رو از اینجا دانلود کن!',
                              ),
                            );
                          },
                        ),
                        Divider(height: 1, indent: 60, color: dividerColor),
                        _buildSettingTile(
                          icon: CupertinoIcons.info_circle_fill,
                          iconBgColor: Colors.blueGrey,
                          title: 'درباره ما',
                          onTap: () => context.pushNamed(AboutScreen.routeName),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // 5. کارت خروج از حساب (کارت مجزا و قرمز رنگ)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isLoading
                                ? null
                                : () => context.read<AuthBloc>().add(
                                    AuthLogOutEvent(),
                                  ),
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.square_arrow_left,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Text(
                                      'خروج از حساب کاربری',
                                      style: TextStyle(
                                        fontFamily: 'CR',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ),
                                  if (isLoading)
                                    const CupertinoActivityIndicator()
                                  else
                                    Icon(
                                      CupertinoIcons.chevron_back,
                                      color: isDark
                                          ? Colors.grey.shade600
                                          : Colors.grey.shade400,
                                      size: 18,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 60)),
            ],
          ),
        ),
      ),
    );
  }

  // ویجت کمکی برای ساخت دکمه‌های زیر پروفایل
  Widget _buildProfileButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.transparent : Colors.grey.shade300,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'CR',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ویجت کمکی برای ساخت ردیف‌های تنظیمات
  Widget _buildSettingTile({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // باکس رنگی پشت آیکون (سبک iOS)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'CR',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              trailing ??
                  Icon(
                    CupertinoIcons
                        .chevron_back, // فلش به سمت چپ برای زبان فارسی
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                    size: 18,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
