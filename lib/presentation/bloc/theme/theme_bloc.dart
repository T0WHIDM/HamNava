import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/presentation/bloc/theme/theme_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/theme/theme_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final prefs = locator<SharedPreferences>();

  ThemeBloc() : super(ThemeState(themeMode: ThemeMode.light)) {
    
    on<LoadThemeEvent>((event, emit) async {
      final isDark = prefs.getBool('isDarkMode') ?? false;
      emit(ThemeState(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
    });

    on<ToggleThemeEvent>((event, emit) async {
      final isCurrentlyDark = state.themeMode == ThemeMode.dark;
      final newMode = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;

      await prefs.setBool('isDarkMode', !isCurrentlyDark);

        emit(ThemeState(themeMode: newMode));
    });
  }
}
