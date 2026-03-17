import 'package:flutter/material.dart';
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
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      label: const Text('نام'),
                      labelStyle: const TextStyle(fontFamily: 'CR'),
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
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      label: const Text('نام کاربری'),
                      labelStyle: const TextStyle(fontFamily: 'CR'),
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
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      label: const Text('ایمیل'),
                      labelStyle: const TextStyle(fontFamily: 'CR'),
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
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      label: const Text('رمز عبور'),
                      labelStyle: const TextStyle(fontFamily: 'CR'),
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
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      label: const Text('تکرار رمز عبور'),
                      labelStyle: const TextStyle(fontFamily: 'CR'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.blueGrey,
                ),
                onPressed: () {},
                child: const Text(
                  'ساخت اکانت',
                  style: TextStyle(
                    fontFamily: 'CR',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
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
