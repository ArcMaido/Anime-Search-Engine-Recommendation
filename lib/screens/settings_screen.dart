import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import 'about_us_screen.dart';
import 'login_screen.dart';
import '../services/session_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.onBackground,
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App settings',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage app information or sign out from your account.',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: colorScheme.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: colorScheme.outline),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: colorScheme.primary),
                  title: Text(
                    'About Us',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  subtitle: Text(
                    'Learn more about SearchNime',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AboutUsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.logout, color: colorScheme.error),
                  title: Text(
                    'Log out',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  subtitle: Text(
                    'Return to the login page',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  onTap: () async {
                    await SessionService.clearCurrentUser();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}