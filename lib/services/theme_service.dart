import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  ThemeService._();

  static const String _themeKey = 'theme_mode';
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.dark);

  static Future<void> loadThemeMode() async {
    final preferences = await SharedPreferences.getInstance();
    final savedTheme = preferences.getString(_themeKey);

    themeMode.value = savedTheme == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  static Future<void> toggleTheme() async {
    final nextTheme =
        themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

    themeMode.value = nextTheme;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _themeKey,
      nextTheme == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}
