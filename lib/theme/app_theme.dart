import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF0075c9);
  static const Color lightBlue = Color(0xFF5BBEFF);
  static const Color deepBlue = Color(0xFF004a8D);
  static const Color limeGreen = Color(0xFFa6ce39);
  static const Color oliveGreen = Color(0xFF7a9a01);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: limeGreen,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      cardTheme: const CardTheme(
        margin: EdgeInsets.all(8),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(fontSize: 16),
      ),
    );
  }
}
