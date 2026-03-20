import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_state.dart';
import 'package:flutter_chat_room_app/presentation/screens/home_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/login_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();

  static String get namedRoute => 'RegisterScreen';
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode userNameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode passwordConfirmFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    nameFocusNode.addListener(() {
      setState(() {});
    });
    userNameFocusNode.addListener(() {
      setState(() {});
    });
    emailFocusNode.addListener(() {
      setState(() {});
    });
    passwordFocusNode.addListener(() {
      setState(() {});
    });
    passwordConfirmFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    nameFocusNode.dispose();
    userNameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    passwordConfirmFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
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
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 44.0,
                  vertical: 22.0,
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextField(
                    focusNode: nameFocusNode,
                    controller: _nameController,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 14, 208, 211),
                        ),
                      ),
                      label: const Text('نام'),
                      labelStyle: TextStyle(
                        fontFamily: 'CR',
                        color: nameFocusNode.hasFocus
                            ? const Color.fromARGB(255, 14, 208, 211)
                            : Colors.black,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 44.0,
                  vertical: 22.0,
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextField(
                    focusNode: userNameFocusNode,
                    controller: _userNameController,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 14, 208, 211),
                        ),
                      ),
                      label: const Text('نام کاربری'),
                      labelStyle: TextStyle(
                        fontFamily: 'CR',
                        color: userNameFocusNode.hasFocus
                            ? const Color.fromARGB(255, 14, 208, 211)
                            : Colors.black,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      prefixText: '@',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 44.0,
                  vertical: 22.0,
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextField(
                    focusNode: emailFocusNode,
                    controller: _emailController,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 14, 208, 211),
                        ),
                      ),
                      label: const Text('ایمیل'),
                      labelStyle: TextStyle(
                        fontFamily: 'CR',
                        color: emailFocusNode.hasFocus
                            ? const Color.fromARGB(255, 14, 208, 211)
                            : Colors.black,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 44.0,
                  vertical: 22.0,
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextField(
                    focusNode: passwordFocusNode,
                    obscureText: true,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 14, 208, 211),
                        ),
                      ),
                      label: const Text('رمز عبور'),
                      labelStyle: TextStyle(
                        fontFamily: 'CR',
                        color: passwordFocusNode.hasFocus
                            ? const Color.fromARGB(255, 14, 208, 211)
                            : Colors.black,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 44.0,
                  vertical: 22.0,
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextField(
                    focusNode: passwordConfirmFocusNode,
                    obscureText: true,
                    controller: _passwordConfirmController,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 14, 208, 211),
                        ),
                      ),
                      label: const Text('تکرار رمز عبور'),
                      labelStyle: TextStyle(
                        fontFamily: 'CR',
                        color: passwordConfirmFocusNode.hasFocus
                            ? const Color.fromARGB(255, 14, 208, 211)
                            : Colors.black,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
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
                        context.goNamed(HomeScreen.namedRoute);
                      },
                    );
                  }
                },
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const CircularProgressIndicator(
                      color: Color.fromARGB(255, 14, 208, 211),
                    );
                  }
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: const Color.fromARGB(255, 14, 208, 211),
                    ),
                    onPressed: () {
                      final name = _nameController.text.trim();
                      final userName = _userNameController.text.trim();
                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();
                      final passwordConfirm = _passwordConfirmController.text
                          .trim();

                      final bool isEmailValid = RegExp(
                        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
                      ).hasMatch(email);

                      final bool englishRegex = RegExp(
                        r'^[A-Z0-9_]+$',
                      ).hasMatch(userName);

                      if (!englishRegex && userName.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              textDirection: TextDirection.rtl,
                              'نام کاربری فقط باید شامل حروف انگلیسی بزرگ و عدد باشد',
                              style: TextStyle(
                                fontFamily: 'CR',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                        return;
                      }

                      if (!isEmailValid && email.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              textDirection: TextDirection.rtl,
                              'لطفاً یک ایمیل معتبر وارد کنید (مثل: example@gmail.com)',
                              style: TextStyle(
                                fontFamily: 'CR',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                        return;
                      }
                      if (password.length < 8 && password.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              textDirection: TextDirection.rtl,
                              "رمز عبور باید حداقل ۸ کاراکتر باشد",
                              style: TextStyle(
                                fontFamily: 'CR',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                        return;
                      }

                      if (password != passwordConfirm) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              textDirection: TextDirection.rtl,
                              "رمز عبور و تکرار ان باید مطابق هم باشند",
                              style: TextStyle(
                                fontFamily: 'CR',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                        return;
                      }

                      if (name.isNotEmpty &&
                          userName.isNotEmpty &&
                          email.isNotEmpty &&
                          password.isNotEmpty &&
                          passwordConfirm.isNotEmpty) {
                        context.read<AuthBloc>().add(
                          AuthRegisterEvent(
                            name,
                            userName,
                            email,
                            password,
                            passwordConfirm,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              textDirection: TextDirection.rtl,
                              'لطفا تمام فیلد ها را کامل کنید',
                              style: TextStyle(
                                fontFamily: 'CR',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'ساخت اکانت',
                      style: TextStyle(
                        fontFamily: 'CR',
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  context.goNamed(LoginScreen.namedRoute);
                },
                child: const Text(
                  'ورود به اکانت',
                  style: TextStyle(
                    color: Color.fromARGB(185, 33, 149, 243),
                    fontFamily: 'CR',
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
