import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import 'app_database.dart';

class SessionService {
  SessionService._();

  static const String _currentUserIdKey = 'current_user_id';

  static Future<void> saveCurrentUser(AppUser user) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_currentUserIdKey, user.id);
  }

  static Future<AppUser?> getCurrentUser() async {
    final preferences = await SharedPreferences.getInstance();
    final userId = preferences.getInt(_currentUserIdKey);

    if (userId == null) {
      return null;
    }

    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      AppDatabase.usersTable,
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (rows.isEmpty) {
      await preferences.remove(_currentUserIdKey);
      return null;
    }

    return AppUser.fromMap(rows.first);
  }

  static Future<void> clearCurrentUser() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_currentUserIdKey);
  }
}