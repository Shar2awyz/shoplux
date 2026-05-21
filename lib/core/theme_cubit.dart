import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'shared_prefs.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit()
      : super(AppPrefs.isDarkMode ? ThemeMode.dark : ThemeMode.light);

  Future<void> setDark(bool isDark) async {
    await AppPrefs.setDarkMode(isDark);
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
