import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/core/utility/go_router_refresh_stream.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_event.dart';
import 'package:flutter_chat_room_app/presentation/customWidget/navigation_bar.dart';
import 'package:flutter_chat_room_app/presentation/screens/about_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/chat_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/create_group_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/friend_list_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/home_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/loading_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/login_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/setting_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/register_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/user_profile_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/user_search_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';

final appGlobalRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,

  refreshListenable: GoRouterRefreshStream(
    locator<PocketBase>().authStore.onChange,
  ),

  redirect: (context, state) {
    final bool isAuthenticated = locator<PocketBase>().authStore.isValid;
    final String currentPath = state.matchedLocation;

    final bool isAuthRoute =
        currentPath == '/loginScreen' || currentPath == '/RegisterScreen';

    if (!isAuthenticated && !isAuthRoute) {
      return '/';
    }

    if (isAuthenticated && isAuthRoute) {
      return '/HomeScreen';
    }

    if (isAuthenticated && currentPath == '/') {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      name: LoadingScreen.routeName,
      path: '/',
      builder: (context, state) {
        return const LoadingScreen();
      },
    ),

    GoRoute(
      name: LoginScreen.namedRoute,
      path: '/loginScreen',
      builder: (context, state) {
        return BlocProvider(
          create: (context) =>
              AuthBloc(locator.get(), locator.get(), locator.get()),
          child: const LoginScreen(),
        );
      },
    ),
    GoRoute(
      name: RegisterScreen.namedRoute,
      path: '/RegisterScreen',
      builder: (context, state) {
        return BlocProvider(
          create: (context) =>
              AuthBloc(locator.get(), locator.get(), locator.get()),
          child: const RegisterScreen(),
        );
      },
    ),
    GoRoute(
      name: AboutScreen.routeName,
      path: '/AboutScreen',
      builder: (context, state) {
        return const AboutScreen();
      },
    ),
    GoRoute(
      path: '/chatScreen/:friendId',
      name: ChatScreen.routeName,
      builder: (context, state) {
        final friendId = state.pathParameters['friendId']!;

        return BlocProvider(
          create: (context) {
            final bloc = ChatBloc(locator.get(), locator.get(), locator.get());
            if (friendId.isNotEmpty) {
              bloc.add(ChatInitializeEvent(friendId));
            }
            return bloc;
          },

          child: ChatScreen(friendId),
        );
      },
    ),

    GoRoute(
      name: UserSearchScreen.routeName,
      path: '/UserSearchScreen',
      builder: (context, state) {
        return BlocProvider(
          create: (context) =>
              UserBloc(locator.get(), locator.get(), locator.get()),
          child: const UserSearchScreen(),
        );
      },
    ),

    GoRoute(
      name: UserProfileScreen.routeName,
      path: '/UserProfileScreen',
      builder: (context, state) {
        return const UserProfileScreen(email: '', name: '', userName: '');
      },
    ),

    GoRoute(
      name: CreateGroupScreen.routeName,
      path: '/CreateGroupScreen',
      builder: (context, state) {
        return const CreateGroupScreen();
      },
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MyBootomNavigationBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/HomeScreen',
              name: HomeScreen.namedRoute,
              builder: (context, state) {
                return const HomeScreen();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/FriendListScreen',
              name: FriendsListScreen.routeName,
              builder: (context, state) {
                final userId = locator<PocketBase>().authStore.record!.id;

                return BlocProvider(
                  create: (context) {
                    final bloc = UserBloc(
                      locator.get(),
                      locator.get(),
                      locator.get(),
                    );
                    if (userId.isNotEmpty) {
                      bloc.add(FriendListEvent(userId));
                    }
                    return bloc;
                  },

                  child: const FriendsListScreen(),
                );
              },
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              name: SettingScreen.routeName,
              path: '/SettingScreen',
              builder: (context, state) {
                return BlocProvider(
                  create: (context) =>
                      AuthBloc(locator.get(), locator.get(), locator.get()),
                  child: const SettingScreen(),
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
