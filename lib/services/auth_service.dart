import 'package:sqflite/sqflite.dart';

import '../models/app_user.dart';
import 'app_database.dart';
import 'session_service.dart';

class AuthService {
  static Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await AppDatabase.instance.database;
    final normalizedEmail = email.trim().toLowerCase();

    final existingUsers = await db.query(
      AppDatabase.usersTable,
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );

    if (existingUsers.isNotEmpty) {
      throw Exception('An account with that email already exists.');
    }

    final id = await db.insert(AppDatabase.usersTable, {
      'name': name.trim(),
      'email': normalizedEmail,
      'password': password,
      'onboarding_completed': 0,
    });

    return AppUser(
      id: id,
      name: name.trim(),
      email: normalizedEmail,
      onboardingCompleted: false,
    );
  }

  static Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final db = await AppDatabase.instance.database;
    final normalizedEmail = email.trim().toLowerCase();

    final users = await db.query(
      AppDatabase.usersTable,
      where: 'email = ? AND password = ?',
      whereArgs: [normalizedEmail, password],
      limit: 1,
    );

    if (users.isEmpty) {
      throw Exception('Invalid email or password.');
    }

    final user = AppUser.fromMap(users.first);
    await SessionService.saveCurrentUser(user);
    return user;
  }

  static Future<void> completeOnboarding(int userId) async {
    final db = await AppDatabase.instance.database;

    await db.update(
      AppDatabase.usersTable,
      {'onboarding_completed': 1},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
