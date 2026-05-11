import 'package:flutter/material.dart';

import 'models/app_user.dart';
import 'screens/home_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'services/session_service.dart';
import 'services/theme_service.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.loadThemeMode();
  runApp(const AniSearchApp());
}

class AniSearchApp extends StatefulWidget {
  const AniSearchApp({Key? key}) : super(key: key);

  @override
  State<AniSearchApp> createState() => _AniSearchAppState();
}

class _AniSearchAppState extends State<AniSearchApp> {
  late final Future<AppUser?> _currentUserFuture;

  @override
  void initState() {
    super.initState();
    _currentUserFuture = SessionService.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeMode,
      builder: (context, themeMode, child) {
        return FutureBuilder<AppUser?>(
          future: _currentUserFuture,
          builder: (context, snapshot) {
            Widget home;

            if (snapshot.connectionState != ConnectionState.done) {
              home = const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else {
              final currentUser = snapshot.data;
              if (currentUser == null) {
                home = const LoginScreen();
              } else if (currentUser.onboardingCompleted) {
                home = HomeScreen(user: currentUser);
              } else {
                home = LandingScreen(user: currentUser);
              }
            }

            return MaterialApp(
              title: 'SearchNime',
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: themeMode,
              debugShowCheckedModeBanner: false,
              home: home,
            );
          },
        );
      },
    );
  }
}
