import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/core/constants/color.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_state.dart';
import 'package:flutter_chat_room_app/presentation/customWidget/custom_snack_bar.dart';
import 'package:flutter_chat_room_app/presentation/screens/chat_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/user_profile_screen.dart';
import 'package:go_router/go_router.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  static String get routeName => 'UserSearchScreen';

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      return;
    }
    context.read<UserBloc>().add(SearchUserEvent(query));
  }

  void _clearSearch() {
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scaffoldBg = isDark ? Colors.black : const Color(0xFFF2F2F7);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final primaryColor = const Color(0xFF0ED0D3);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(CupertinoIcons.back),
        ),
        title: const Text(
          'جستجوی دوستان',
          style: TextStyle(
            fontFamily: 'CR',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is AddFriendComplatedState) {
            state.result.fold(
              (failure) {
                final snackbar = buildCustomSnackBar(
                  color: CustomColor.red,
                  message: failure.message,
                  title: 'failure',
                  type: .failure,
                );

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(snackbar);
              },
              (success) {
                final snackbar = buildCustomSnackBar(
                  color: CustomColor.green,
                  message: 'درخواست دوستی ارسال شد',
                  title: 'success',
                  type: .success,
                );

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(snackbar);
              },
            );
          }
        },
        child: Column(
          children: [
            //text field
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: CupertinoSearchTextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  placeholder: 'نام کاربری را وارد کنید...',
                  style: TextStyle(
                    fontFamily: 'CR',
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  suffixMode: OverlayVisibilityMode.editing,
                  suffixIcon: const Icon(CupertinoIcons.xmark_circle_fill),
                  onSuffixTap: _clearSearch,
                ),
              ),
            ),

            Expanded(
              child: BlocBuilder<UserBloc, UserState>(
                buildWhen: (previous, current) {
                  return current is! AddFriendLoadingState &&
                      current is! AddFriendComplatedState;
                },
                builder: (context, state) {
                  if (_searchController.text.trim().isEmpty) {
                    return _buildEmptyState();
                  }

                  if (state is UserSearchLoadingState) {
                    return const Center(
                      child: CupertinoActivityIndicator(radius: 14),
                    );
                  } else if (state is UserSearchComplatedsState) {
                    return state.result.fold(
                      (exception) => _buildErrorWidget(exception.message),
                      (users) => _buildUserList(users, cardBg, primaryColor),
                    );
                  }

                  return _buildEmptyState();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(
    List<UserEntity> users,
    Color cardBg,
    Color primaryColor,
  ) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.person_2, color: Colors.grey, size: 70),
            const SizedBox(height: 16),
            const Text(
              'کاربری پیدا نشد',
              style: TextStyle(
                fontFamily: 'CR',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            Text(
              'لطفاً نام کاربری دیگری را امتحان کنید',
              style: TextStyle(
                fontFamily: 'CR',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: users.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              onTap: () =>
                  context.pushNamed(UserProfileScreen.routeName, extra: user),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: primaryColor.withValues(alpha: .2),
                child: Icon(CupertinoIcons.person_fill, color: primaryColor),
              ),
              title: Text(
                user.name,
                style: const TextStyle(fontFamily: 'GB', fontSize: 16),
              ),
              subtitle: Text(
                '@${user.userName}',
                style: TextStyle(
                  fontFamily: 'CR',
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      CupertinoIcons.chat_bubble_text_fill,
                      color: primaryColor,
                    ),
                    onPressed: () {
                      context.pushNamed(
                        ChatScreen.routeName,
                        extra: user,
                        pathParameters: {'friendId': user.id},
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.person_add,
                      color: CupertinoColors.activeBlue,
                    ),
                    onPressed: () {
                      context.read<UserBloc>().add(AddFriendEvent(user.id));
                    },
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.grey.withValues(alpha: .2),
            indent: 72,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.xmark_octagon,
            color: CupertinoColors.destructiveRed,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'خطایی رخ داد',
            style: TextStyle(
              fontFamily: 'GB',
              fontSize: 18,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(fontFamily: 'CR', color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CupertinoColors.activeBlue.withValues(alpha: .1),
            ),
            child: const Icon(
              CupertinoIcons.search,
              size: 50,
              color: CupertinoColors.activeBlue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'دوستان خود را پیدا کنید',
            style: TextStyle(
              fontFamily: 'cr',
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'برای شروع، نام کاربری مورد نظر را در بالا وارد کنید',
            style: TextStyle(fontFamily: 'CR', color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
