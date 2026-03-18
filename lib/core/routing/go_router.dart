import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_bloc.dart';
import 'package:flutter_chat_room_app/presentation/customWidget/navigation_bar.dart';
import 'package:flutter_chat_room_app/presentation/screens/about_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/chat_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/home_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/loading_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/login_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/setting_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/register_screen.dart';
import 'package:go_router/go_router.dart';



final appGlobalRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
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
      name: ChatScreen.routeName,
      path: '/ChatScreen',
      builder: (context, state) {
        return const ChatScreen();
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
