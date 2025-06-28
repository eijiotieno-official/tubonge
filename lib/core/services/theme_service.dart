import 'package:flutter/material.dart';

class ThemeService {
  static Color get primaryColor => Colors.green;

  static FilledButtonThemeData get filledButtonTheme => FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size(double.infinity, 50),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      );

  static ProgressIndicatorThemeData get progressIndicatorTheme =>
      ProgressIndicatorThemeData(
        strokeCap: StrokeCap.round,
        color: primaryColor,
      );

  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(8.0),
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        filledButtonTheme: filledButtonTheme,
        progressIndicatorTheme: progressIndicatorTheme,
        inputDecorationTheme: inputDecorationTheme,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ).copyWith(primary: primaryColor, secondary: primaryColor),
      );

  static ThemeData get darkTheme => ThemeData(
        filledButtonTheme: filledButtonTheme,
        progressIndicatorTheme: progressIndicatorTheme,
        inputDecorationTheme: inputDecorationTheme,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ).copyWith(primary: primaryColor, secondary: primaryColor),
      );
}
