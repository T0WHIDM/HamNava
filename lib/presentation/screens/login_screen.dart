import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_state.dart';
import 'package:flutter_chat_room_app/presentation/screens/home_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/register_screen.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();

  static String get namedRoute => 'loginScreen';
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: .15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          CupertinoIcons.chat_bubble_2_fill,
                          size: 40,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'خوش آمدید',
                      style: TextStyle(
                        fontFamily: 'CR',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'برای ادامه وارد حساب کاربری خود شوید',
                      style: TextStyle(
                        fontFamily: 'CR',
                        fontSize: 14,
                        color: hintColor,
                      ),
                    ),
                    const SizedBox(height: 32),

                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextFormField(
                        controller: _usernameController,
                        style: TextStyle(
                          fontFamily: 'CR',
                          color: textColor,
                          fontSize: 16,
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.emailAddress,
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
                          hintColor: hintColor!,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

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
                            return 'لطفاً رمز عبور خود را وارد کنید';
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
                    const SizedBox(height: 32),

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
                                  backgroundColor: const Color(
                                    0xFFFF3B30,
                                  ), 
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
                              foregroundColor: Colors
                                  .black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final username = _usernameController.text
                                    .trim();
                                final password = _passwordController.text
                                    .trim();

                                context.read<AuthBloc>().add(
                                  AuthLoginEvent(username, password),
                                );
                              }
                            },
                            child: const Text(
                              'ورود به حساب',
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

                    // لینک ثبت نام
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      textDirection: TextDirection.rtl,
                      children: [
                        Text(
                          'حساب کاربری ندارید؟',
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
                            context.goNamed(RegisterScreen.namedRoute);
                          },
                          child: const Text(
                            'ثبت نام کنید',
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
              ? Colors.white.withValues(alpha: .05)
              : Colors.black.withValues(alpha: .05),
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
        ), 
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 1.5),
      ),
    );
  }
}
