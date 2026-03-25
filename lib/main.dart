import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      create: (context) => ThemeBloc()..add(LoadThemeEvent()),
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

        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xffF5F5F5),
          cardColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xffF5F5F5),
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(color: Colors.black),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.grey[900],
          cardColor: Colors.grey[850],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[900],
            iconTheme: const IconThemeData(color: Colors.white),
            titleTextStyle: const TextStyle(color: Colors.white),
          ),
        ),

        themeMode: state.themeMode,
      ),
    );
  }
}
