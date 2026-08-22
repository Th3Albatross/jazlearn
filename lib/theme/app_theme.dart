import 'package:flutter/material.dart';

class AppTheme {
  static const green = Color(0xFF405238);
  static const darkGreen = Color(0xFF283722);
  static const brown = Color(0xFF784721);
  static const gold = Color(0xFFD5B06A);
  static const cream = Color(0xFFF5EAD4);
  static const paper = Color(0xFFF8EEDB);
  static const text = Color(0xFF3B2A1E);
  static const muted = Color(0xFF806C5A);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cream,
      fontFamily: 'Georgia',
      colorScheme: ColorScheme.fromSeed(
        seedColor: green,
        brightness: Brightness.light,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: text,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: TextStyle(
          color: text,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: text,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(
          color: muted,
          fontFamily: 'Arial',
        ),
      ),
    );
  }
}

