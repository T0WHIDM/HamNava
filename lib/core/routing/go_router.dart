import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/core/utility/go_router_refresh_stream.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_event.dart';
import 'package:flutter_chat_room_app/presentation/customWidget/navigation_bar.dart';
import 'package:flutter_chat_room_app/presentation/screens/about_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/chat_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/create_group_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/edit_profile_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/friend_list_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/group_chat_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/group_info.dart';
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
    //loading
    GoRoute(
      name: LoadingScreen.routeName,
      path: '/',
      builder: (context, state) {
        return const LoadingScreen();
      },
    ),

    //login
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

    //register
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

    //about
    GoRoute(
      name: AboutScreen.routeName,
      path: '/AboutScreen',
      builder: (context, state) {
        return const AboutScreen();
      },
    ),

    //chat
    GoRoute(
      path: '/chatScreen/:friendId',
      name: ChatScreen.routeName,
      builder: (context, state) {
        final friendId = state.pathParameters['friendId']!;

        final friend = state.extra as UserEntity;

        return BlocProvider(
          create: (context) {
            final bloc = ChatBloc(
              locator.get(),
              locator.get(),
              locator.get(),
              locator.get(),
              locator.get(),
              locator.get(),
              locator.get(),
              locator.get(),
              locator.get(),
            );
            if (friendId.isNotEmpty) {
              bloc.add(ChatInitializeEvent(friendId));
            }
            return bloc;
          },
          child: ChatScreen(friend),
        );
      },
    ),

    //userSearch
    GoRoute(
      name: UserSearchScreen.routeName,
      path: '/UserSearchScreen',
      builder: (context, state) {
        return BlocProvider(
          create: (context) => UserBloc(
            locator.get(),
            locator.get(),
            locator.get(),
            locator.get(),
            updateProfileUseCase: locator.get(),
          ),
          child: const UserSearchScreen(),
        );
      },
    ),

    //userProfile
    GoRoute(
      name: UserProfileScreen.routeName,
      path: '/UserProfileScreen',
      builder: (context, state) {
        final user = state.extra as UserEntity;

        return UserProfileScreen(user);
      },
    ),

    //createGroup
    GoRoute(
      path: '/CreateGroup',
      name: CreateGroupScreen.routeName,
      builder: (context, state) {
        final userId = locator<PocketBase>().authStore.record!.id;

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ChatBloc(
                locator.get(),
                locator.get(),
                locator.get(),
                locator.get(),
                locator.get(),
                locator.get(),
                locator.get(),
                locator.get(),
                locator.get(),
              ),
            ),

            BlocProvider(
              create: (context) {
                final userBloc = UserBloc(
                  locator.get(),
                  locator.get(),
                  locator.get(),
                  locator.get(),
                  updateProfileUseCase: locator.get(),
                );

                userBloc.add(FriendListEvent(userId));

                return userBloc;
              },
            ),
          ],
          child: const CreateGroupScreen(),
        );
      },
    ),

    //editProfile
    GoRoute(
      name: EditProfileScreen.routeNmae,
      path: '/EditProfileScreen',
      builder: (context, state) {
        if (state.extra is UserEntity) {
          final user = state.extra as UserEntity;

          return BlocProvider(
            create: (context) => UserBloc(
              updateProfileUseCase: locator.get(),
              locator.get(),
              locator.get(),
              locator.get(),
              locator.get(),
            ),
            child: EditProfileScreen(currentUser: user),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(SettingScreen.routeName);
            }
          }
        });

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    ),

    //groupChatScreen
    GoRoute(
      path: '/GroupChatScreen',
      name: GroupChatScreen.routeName,
      builder: (context, state) {
        final conversation = state.extra as ConversationEntity;
        return BlocProvider(
          create: (context) => ChatBloc(
            locator.get(),
            locator.get(),
            locator.get(),
            locator.get(),
            locator.get(),
            locator.get(),
            locator.get(),
            locator.get(),
            locator.get(),
          ),
          child: GroupChatScreen(conversation: conversation),
        );
      },
    ),

    //groupInfoScreen
    GoRoute(
      path: '/GroupInfoScreen',
      name: GroupInfoScreen.routeName,
      builder: (context, state) {
        final conversation = state.extra as ConversationEntity;
        return GroupInfoScreen(conversation: conversation);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MyBootomNavigationBar(navigationShell: navigationShell);
      },
      branches: [
        //home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/HomeScreen',
              name: HomeScreen.namedRoute,
              builder: (context, state) {
                final userId = locator<PocketBase>().authStore.record!.id;

                return BlocProvider(
                  create: (context) {
                    final bloc = ChatBloc(
                      locator.get(),
                      locator.get(),
                      locator.get(),
                      locator.get(),
                      locator.get(),
                      locator.get(),
                      locator.get(),
                      locator.get(),
                      locator.get(),
                    );
                    if (userId.isNotEmpty) {
                      bloc.add(GetChatListEvent(userId));
                    }
                    return bloc;
                  },
                  child: const HomeScreen(),
                );
              },
            ),
          ],
        ),

        //friendList
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
                      locator.get(),
                      updateProfileUseCase: locator.get(),
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

        //setting
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: SettingScreen.routeName,
              path: '/SettingScreen',
              builder: (context, state) {
                final currentUserId =
                    locator<PocketBase>().authStore.record?.id ?? '';

                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) =>
                          AuthBloc(locator.get(), locator.get(), locator.get()),
                    ),

                    BlocProvider(
                      create: (context) {
                        final userBloc = UserBloc(
                          locator.get(),
                          locator.get(),
                          locator.get(),
                          locator.get(),
                          updateProfileUseCase: locator.get(),
                        );

                        userBloc.add(ProfileInfoEvent(currentUserId));

                        return userBloc;
                      },
                    ),
                  ],
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
