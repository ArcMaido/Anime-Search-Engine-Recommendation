import 'package:flutter/material.dart';

import '../services/theme_service.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeMode,
      builder: (context, themeMode, child) {
        final isDark = themeMode == ThemeMode.dark;
        return IconButton(
          tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
          onPressed: ThemeService.toggleTheme,
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
        );
      },
    );
  }
}
