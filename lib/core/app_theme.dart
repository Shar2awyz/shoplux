import 'package:flutter/material.dart';
import '../constants/AppColors.dart';
import 'app_color_scheme.dart';

class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.fieldBackground,
          onSurface: AppColors.white,
          onPrimary: Colors.white,
        ),
        cardColor: AppColors.fieldBackground,
        dividerColor: AppColors.divider,
        useMaterial3: true,
        extensions: const [AppColorScheme.dark],
        snackBarTheme: const SnackBarThemeData(
          contentTextStyle: TextStyle(color: Colors.white),
          actionTextColor: AppColors.primary,
        ),
      );

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xffF2F3F7),
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          surface: Colors.white,
          onSurface: Color(0xff1A1A2E),
          onPrimary: Colors.white,
        ),
        cardColor: Colors.white,
        dividerColor: const Color(0xffE0E0E0),
        useMaterial3: true,
        extensions: const [AppColorScheme.light],
        snackBarTheme: const SnackBarThemeData(
          contentTextStyle: TextStyle(color: Color(0xff1A1A2E)),
          actionTextColor: AppColors.primary,
        ),
      );
}
