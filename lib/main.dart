import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/core/constants/theme.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/core/routing/go_router.dart';
import 'package:flutter_chat_room_app/presentation/bloc/theme/theme_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/theme/theme_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/theme/theme_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await getItInit();

  runApp(
    BlocProvider(
      create: (context) => ThemeBloc(locator.get())..add(LoadThemeEvent()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'HamNava',
        routerConfig: appGlobalRouter,
        theme: MyTheme.lightMode,
        darkTheme: MyTheme.darkMode,
        themeMode: state.themeMode,
      ),
    );
  }
}
