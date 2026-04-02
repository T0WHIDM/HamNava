import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_state.dart';
import 'package:flutter_chat_room_app/presentation/screens/home_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/login_screen.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();

  static String get namedRoute => 'RegisterScreen';
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  File? _selectedAvatar;

  // متغیرهای مدیریت نمایش رمز عبور
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void dispose() {
    _nameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // تشخیص حالت دارک مود
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // پالت رنگی پریمیوم
    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final primaryColor = const Color(0xFF0ED0D3);
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.grey[500] : Colors.grey[400];

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // تیتر صفحه
                    Text(
                      'ایجاد حساب کاربری',
                      style: TextStyle(
                        fontFamily: 'CR',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'اطلاعات خود را برای ثبت‌نام وارد کنید',
                      style: TextStyle(
                        fontFamily: 'CR',
                        fontSize: 14,
                        color: hintColor,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // بخش انتخاب عکس پروفایل به سبک iOS
                    Stack(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cardColor,
                            border: Border.all(
                              color: isDark ? Colors.white10 : Colors.black12,
                              width: 2,
                            ),
                          ),
                          child: _selectedAvatar == null
                              ? Icon(
                                  CupertinoIcons.person_solid,
                                  size: 55,
                                  color: hintColor,
                                )
                              : ClipOval(
                                  child: Image.file(
                                    _selectedAvatar!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () {
                              // اکشن انتخاب عکس
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor,
                                border: Border.all(color: bgColor, width: 3),
                              ),
                              child: const Icon(
                                CupertinoIcons.camera_fill,
                                size: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // فیلد نام
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextFormField(
                        controller: _nameController,
                        style: TextStyle(
                          fontFamily: 'CR',
                          color: textColor,
                          fontSize: 16,
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'لطفاً نام خود را وارد کنید';
                          }
                          return null;
                        },
                        decoration: _buildInputDecoration(
                          isDark: isDark,
                          hint: 'نام و نام خانوادگی',
                          icon: CupertinoIcons.person,
                          cardColor: cardColor,
                          primaryColor: primaryColor,
                          hintColor: hintColor!,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // فیلد نام کاربری
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextFormField(
                        controller: _userNameController,
                        style: TextStyle(
                          fontFamily: 'CR',
                          color: textColor,
                          fontSize: 16,
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'لطفاً نام کاربری را وارد کنید';
                          }
                          final englishRegex = RegExp(r'^[a-z0-9_]+$');
                          if (!englishRegex.hasMatch(value)) {
                            return 'فقط حروف انگلیسی کوچک، عدد و _ مجاز است';
                          }
                          return null;
                        },
                        decoration: _buildInputDecoration(
                          isDark: isDark,
                          hint: 'نام کاربری',
                          icon: CupertinoIcons.at,
                          cardColor: cardColor,
                          primaryColor: primaryColor,
                          hintColor: hintColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // فیلد ایمیل
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextFormField(
                        controller: _emailController,
                        style: TextStyle(
                          fontFamily: 'CR',
                          color: textColor,
                          fontSize: 16,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'لطفاً ایمیل خود را وارد کنید';
                          }
                          final bool isEmailValid = RegExp(
                            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
                          ).hasMatch(value);
                          if (!isEmailValid) {
                            return 'لطفاً یک ایمیل معتبر وارد کنید';
                          }
                          return null;
                        },
                        decoration: _buildInputDecoration(
                          isDark: isDark,
                          hint: 'ایمیل',
                          icon: CupertinoIcons.mail,
                          cardColor: cardColor,
                          primaryColor: primaryColor,
                          hintColor: hintColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // فیلد رمز عبور
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _isPasswordObscured,
                        style: TextStyle(
                          fontFamily: 'CR',
                          color: textColor,
                          fontSize: 16,
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'لطفاً رمز عبور را وارد کنید';
                          }
                          if (value.length < 8) {
                            return 'رمز عبور باید حداقل ۸ کاراکتر باشد';
                          }
                          return null;
                        },
                        decoration:
                            _buildInputDecoration(
                              isDark: isDark,
                              hint: 'رمز عبور',
                              icon: CupertinoIcons.lock,
                              cardColor: cardColor,
                              primaryColor: primaryColor,
                              hintColor: hintColor,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordObscured
                                      ? CupertinoIcons.eye
                                      : CupertinoIcons.eye_slash,
                                  color: hintColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordObscured = !_isPasswordObscured;
                                  });
                                },
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // فیلد تکرار رمز عبور
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextFormField(
                        controller: _passwordConfirmController,
                        obscureText: _isConfirmPasswordObscured,
                        style: TextStyle(
                          fontFamily: 'CR',
                          color: textColor,
                          fontSize: 16,
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'لطفاً تکرار رمز عبور را وارد کنید';
                          }
                          if (value != _passwordController.text) {
                            return 'رمز عبور و تکرار آن مطابقت ندارند';
                          }
                          return null;
                        },
                        decoration:
                            _buildInputDecoration(
                              isDark: isDark,
                              hint: 'تکرار رمز عبور',
                              icon: CupertinoIcons.lock_shield,
                              cardColor: cardColor,
                              primaryColor: primaryColor,
                              hintColor: hintColor,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordObscured
                                      ? CupertinoIcons.eye
                                      : CupertinoIcons.eye_slash,
                                  color: hintColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordObscured =
                                        !_isConfirmPasswordObscured;
                                  });
                                },
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // دکمه ثبت نام / لودینگ
                    BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthSuccess) {
                          state.result.fold(
                            (failure) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: const Color(0xFFFF3B30),
                                  content: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Text(
                                      failure.message,
                                      style: const TextStyle(
                                        fontFamily: 'CR',
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            (success) {
                              context.goNamed(HomeScreen.namedRoute);
                            },
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: cardColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: CupertinoActivityIndicator(
                                radius: 14,
                                color: primaryColor,
                              ),
                            ),
                          );
                        }
                        return SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                context.read<AuthBloc>().add(
                                  AuthRegisterEvent(
                                    _nameController.text.trim(),
                                    _userNameController.text.trim(),
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                    _passwordConfirmController.text.trim(),
                                    // _selectedAvatar,
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'ساخت حساب',
                              style: TextStyle(
                                fontFamily: 'CR',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // لینک ورود به اکانت
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      textDirection: TextDirection.rtl,
                      children: [
                        Text(
                          'از قبل حساب دارید؟',
                          style: TextStyle(
                            fontFamily: 'CR',
                            fontSize: 14,
                            color: hintColor,
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          onPressed: () {
                            context.goNamed(LoginScreen.namedRoute);
                          },
                          child: const Text(
                            'وارد شوید',
                            style: TextStyle(
                              fontFamily: 'CR',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // متد کمکی برای استایل‌دهی یکپارچه به فیلدها
  InputDecoration _buildInputDecoration({
    required bool isDark,
    required String hint,
    required IconData icon,
    required Color cardColor,
    required Color primaryColor,
    required Color hintColor,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: cardColor,
      hintText: hint,
      hintStyle: TextStyle(fontFamily: 'CR', color: hintColor, fontSize: 15),
      prefixIcon: Icon(icon, color: hintColor, size: 22),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFFF3B30),
          width: 1.2,
        ), // قرمز استاندارد iOS
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 1.5),
      ),
    );
  }
}
