import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF0F172A);
  static const Color cardBackground = Color(0xFF18253D);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF22D3EE);
  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color greyText = Color(0xFFCBD5E1);
  static const Color darkGrey = Color(0xFF334155);

  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF4F46E5);
  static const Color lightAccent = Color(0xFF0EA5E9);
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightMuted = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPurple,
        brightness: Brightness.dark,
        surface: cardBackground,
      ).copyWith(
        primary: primaryPurple,
        secondary: accentCyan,
        surface: cardBackground,
        onSurface: whiteText,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
      ),
      // Card theming - keep default types to ensure SDK compatibility
      // Custom card styling applied via Card widgets individually where needed.
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: whiteText,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: whiteText,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: whiteText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: whiteText,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: whiteText,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: greyText,
          fontSize: 14,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryPurple),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
        hintStyle: const TextStyle(color: greyText),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lightPrimary,
        brightness: Brightness.light,
        surface: lightCardBackground,
      ).copyWith(
        primary: lightPrimary,
        secondary: lightAccent,
        surface: lightCardBackground,
        onSurface: lightText,
      ),
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightText,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: lightText,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: lightText,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: lightText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: lightText,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: lightText,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: lightMuted,
          fontSize: 14,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightPrimary, width: 2),
        ),
        hintStyle: const TextStyle(color: lightMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightCardBackground,
        side: const BorderSide(color: lightBorder),
        labelStyle: const TextStyle(color: lightText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}
