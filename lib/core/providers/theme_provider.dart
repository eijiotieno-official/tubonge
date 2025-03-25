import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _themeData = ThemeData(
  colorSchemeSeed: Colors.green.shade300,
);

final lightThemeProvider = Provider<ThemeData>((ref) {
  return _themeData.copyWith(
    brightness: Brightness.light,
  );
});

final darkThemeProvider = Provider<ThemeData>((ref) {
  return _themeData.copyWith(
    brightness: Brightness.dark,
  );
});
