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
        final colorScheme = Theme.of(context).colorScheme;

        return IconButton.filledTonal(
          tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
          onPressed: ThemeService.toggleTheme,
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer.withOpacity(0.8),
            foregroundColor: colorScheme.primary,
          ),
          icon: Icon(
            isDark ? Icons.sunny : Icons.nightlight_round,
          ),
        );
      },
    );
  }
}
