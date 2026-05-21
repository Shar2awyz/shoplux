import 'package:flutter/material.dart';

class AppColorScheme extends ThemeExtension<AppColorScheme> {
  final Color background;
  final Color fieldBackground;
  final Color text;
  final Color grey;
  final Color fieldBorder;
  final Color divider;
  final List<Color> cardBackgrounds;

  const AppColorScheme({
    required this.background,
    required this.fieldBackground,
    required this.text,
    required this.grey,
    required this.fieldBorder,
    required this.divider,
    required this.cardBackgrounds,
  });

  static const dark = AppColorScheme(
    background: Color(0xff050816),
    fieldBackground: Color(0xff141726),
    text: Colors.white,
    grey: Color(0xff8B8FA8),
    fieldBorder: Colors.white10,
    divider: Colors.white10,
    cardBackgrounds: [
      Color(0xff1E0900),
      Color(0xff0A1520),
      Color(0xff0D1A0D),
      Color(0xff1A0A1A),
      Color(0xff1A1A0A),
      Color(0xff0A1A1A),
    ],
  );

  static const light = AppColorScheme(
    background: Color(0xffF2F3F7),
    fieldBackground: Colors.white,
    text: Color(0xff1A1A2E),
    grey: Color(0xff6B7280),
    fieldBorder: Color(0xffE0E0E0),
    divider: Color(0xffE0E0E0),
    cardBackgrounds: [
      Color(0xffFFF0E8),
      Color(0xffE8F0FF),
      Color(0xffE8FFE8),
      Color(0xffF5E8FF),
      Color(0xffFFFAE8),
      Color(0xffE8FAFF),
    ],
  );

  @override
  AppColorScheme copyWith({
    Color? background,
    Color? fieldBackground,
    Color? text,
    Color? grey,
    Color? fieldBorder,
    Color? divider,
    List<Color>? cardBackgrounds,
  }) =>
      AppColorScheme(
        background: background ?? this.background,
        fieldBackground: fieldBackground ?? this.fieldBackground,
        text: text ?? this.text,
        grey: grey ?? this.grey,
        fieldBorder: fieldBorder ?? this.fieldBorder,
        divider: divider ?? this.divider,
        cardBackgrounds: cardBackgrounds ?? this.cardBackgrounds,
      );

  @override
  AppColorScheme lerp(AppColorScheme other, double t) => AppColorScheme(
        background: Color.lerp(background, other.background, t)!,
        fieldBackground:
            Color.lerp(fieldBackground, other.fieldBackground, t)!,
        text: Color.lerp(text, other.text, t)!,
        grey: Color.lerp(grey, other.grey, t)!,
        fieldBorder: Color.lerp(fieldBorder, other.fieldBorder, t)!,
        divider: Color.lerp(divider, other.divider, t)!,
        cardBackgrounds: List.generate(
          cardBackgrounds.length,
          (i) => Color.lerp(
            cardBackgrounds[i],
            other.cardBackgrounds[i % other.cardBackgrounds.length],
            t,
          )!,
        ),
      );
}

extension AppThemeContext on BuildContext {
  AppColorScheme get colors =>
      Theme.of(this).extension<AppColorScheme>() ?? AppColorScheme.dark;
}
