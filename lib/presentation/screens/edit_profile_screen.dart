import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_state.dart';
import 'package:go_router/go_router.dart';

class EditProfileScreen extends StatefulWidget {
  final UserEntity currentUser;

  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();

  static String get routeNmae => 'editProfileScreens';
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode userNameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();

  @override
  void initState() {
    nameFocusNode.addListener(() {
      setState(() {});
    });

    userNameFocusNode.addListener(() {
      setState(() {});
    });

    emailFocusNode.addListener(() {
      setState(() {});
    });

    super.initState();
    _nameController = TextEditingController(text: widget.currentUser.name);
    _emailController = TextEditingController(text: widget.currentUser.email);
    _usernameController = TextEditingController(
      text: widget.currentUser.userName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    nameFocusNode.dispose();
    userNameFocusNode.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final newName = _nameController.text.trim();
      final newEmail = _emailController.text.trim();
      final newUsername = _usernameController.text.trim();

      context.read<UserBloc>().add(
        UpdateProfileInfoEvent(
          widget.currentUser.id,
          newUsername,
          newEmail,
          newName,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ویرایش پروفایل',
          style: TextStyle(fontFamily: 'cr', fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UpdateProfileInfoSuccessState) {
            state.update.fold(
              (failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.red,
                    content: Text(
                      failure.message,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontFamily: 'cr'),
                    ),
                  ),
                );
              },
              (updatedUser) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                    content: Text(
                      'پروفایل با موفقیت به‌روزرسانی شد',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontFamily: 'cr'),
                    ),
                  ),
                );
                context.pop();
              },
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                    focusNode: nameFocusNode,
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'نام و نام خانوادگی',
                      labelStyle: TextStyle(
                        fontFamily: 'cr',
                        color: nameFocusNode.hasFocus
                            ? const Color.fromARGB(255, 14, 208, 211)
                            : isDark
                            ? Colors.white
                            : Colors.black,
                      ),
                      prefixIcon: const Icon(Icons.person),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 14, 208, 211),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'لطفاً نام خود را وارد کنید';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 32),

                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                    focusNode: userNameFocusNode,
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'نام کاربری (یوزرنیم)',
                      labelStyle: TextStyle(
                        fontFamily: 'cr',
                        color: userNameFocusNode.hasFocus
                            ? const Color.fromARGB(255, 14, 208, 211)
                            : isDark
                            ? Colors.white
                            : Colors.black,
                      ),
                      prefixIcon: const Icon(Icons.alternate_email),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 14, 208, 211),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'لطفاً نام کاربری را وارد کنید';
                      }
                      if (value.length < 3) {
                        return 'نام کاربری باید حداقل ۳ حرف باشد';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 32),

                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                    focusNode: emailFocusNode,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'ایمیل',
                      labelStyle: TextStyle(
                        fontFamily: 'cr',
                        color: emailFocusNode.hasFocus
                            ? const Color.fromARGB(255, 14, 208, 211)
                            : isDark
                            ? Colors.white
                            : Colors.black,
                      ),
                      prefixIcon: const Icon(Icons.email),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 14, 208, 211),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'لطفاً ایمیل خود را وارد کنید';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'لطفاً یک ایمیل معتبر وارد کنید';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 32),

                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    if (state is UpdateProfileInfoLoadingState) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 14, 208, 211),
                        ),
                      );
                    }

                    return ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          14,
                          208,
                          211,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'ذخیره تغییرات',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'cr',
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
    );
  }
}
