import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';

final themeProvider = Provider.family<ThemeData, BuildContext>(
  (ref, context) {
    double fontSize = getValueForScreenType<double>(
      context: context,
      mobile: 14,
      tablet: 14,
      desktop: 16,
    );

    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.greenAccent,
      brightness: Brightness.light,
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: 36.0,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(fontSize: 18.0),
        labelMedium: TextStyle(
          fontSize: fontSize,
          color: Colors.black.withOpacity(0.55),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorStyle: TextStyle(fontSize: 16.0),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size(double.infinity, 55)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.disabled)
                ? Colors.grey.shade400
                : null,
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.disabled)
                ? Colors.white.withOpacity(0.6)
                : null,
          ),
        ),
      ),
    );
  },
);
