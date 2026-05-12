import 'package:flutter/material.dart';

import 'about_us_screen.dart';
import '../services/app_database.dart';
import '../utils/app_theme.dart';

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
                  'Manage app information and app preferences.',
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
                  leading: Icon(Icons.delete_outline, color: colorScheme.error),
                  title: Text(
                    'Clear Data',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  subtitle: Text(
                    'Remove saved anime interaction history',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  onTap: () async {
                    final shouldClear = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text('Clear data?'),
                          content: const Text(
                            'This will remove the saved anime categories used for recommendations.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(dialogContext).pop(true),
                              child: const Text('Clear'),
                            ),
                          ],
                        );
                      },
                    );

                    if (shouldClear != true) {
                      return;
                    }

                    await AppDatabase.instance.clearAnimeInteractions();
                    await AppDatabase.instance.clearActiveCategories();

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.of(context).pop(true);
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