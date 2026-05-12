import 'package:flutter/material.dart';

import 'models/app_user.dart';
import 'screens/home_screen.dart';
import 'services/theme_service.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.loadThemeMode();
  runApp(const SearchNimeApp());
}

class SearchNimeApp extends StatelessWidget {
  const SearchNimeApp({Key? key}) : super(key: key);

  static const AppUser _guestUser = AppUser(
    id: 0,
    name: 'Guest',
    email: 'guest@searchnime.local',
    onboardingCompleted: true,
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'SearchNime',
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          home: HomeScreen(user: _guestUser),
        );
      },
    );
  }
}
