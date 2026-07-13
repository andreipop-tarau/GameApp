import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double small = 8;
  static const double medium = 16;
  static const double large = 24;
}

final ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(fontWeight: FontWeight.bold),
  ),
  useMaterial3: true,
);
