import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/recommendation_anime.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String _databaseName = 'searchnime.db';
  static const int _databaseVersion = 4;
  static const String _activeCategoriesKey = 'active_categories';
  static const int _maxStoredCategories = 10;

  static const String usersTable = 'users';
  static const String animeTable = 'anime_catalog';
  static const String interactionsTable = 'anime_interactions';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $interactionsTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          anime_id INTEGER NOT NULL,
          anime_title TEXT NOT NULL,
          categories TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');

      try {
        await db.execute(
          'ALTER TABLE $usersTable ADD COLUMN onboarding_completed INTEGER NOT NULL DEFAULT 1',
        );
      } catch (_) {
        // Column already exists on newer installs.
      }
    }

    if (oldVersion < 4) {
      await _seedAnimeCatalog(db);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $usersTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        onboarding_completed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE $interactionsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        anime_id INTEGER NOT NULL,
        anime_title TEXT NOT NULL,
        categories TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $animeTable (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        synopsis TEXT NOT NULL,
        image_url TEXT,
        categories TEXT NOT NULL,
        score REAL NOT NULL
      )
    ''');

    await _seedAnimeCatalog(db);
  }

  Future<void> _seedAnimeCatalog(Database db) async {
    final batch = db.batch();

    for (final anime in _seedRecommendations) {
      batch.insert(
        animeTable,
        {
        'id': anime.id,
        'title': anime.title,
        'synopsis': anime.synopsis,
        'image_url': anime.imageUrl,
        'categories': anime.categories.join(', '),
        'score': anime.score,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> saveAnimeInteraction({
    required int userId,
    required int animeId,
    required String animeTitle,
    required List<String> categories,
  }) async {
    final normalizedCategories = _normalizeCategories(categories);

    if (normalizedCategories.isEmpty) {
      return;
    }

    final db = await database;
    final existingRows = await db.query(
      interactionsTable,
      columns: ['id'],
      where: 'user_id = ? AND anime_id = ?',
      whereArgs: [userId, animeId],
      limit: 1,
    );

    final values = {
      'user_id': userId,
      'anime_id': animeId,
      'anime_title': animeTitle,
      'categories': normalizedCategories.join(', '),
      'created_at': DateTime.now().toIso8601String(),
    };

    if (existingRows.isEmpty) {
      await db.insert(interactionsTable, values);
      return;
    }

    await db.update(
      interactionsTable,
      values,
      where: 'user_id = ? AND anime_id = ?',
      whereArgs: [userId, animeId],
    );
  }

  Future<Map<String, int>> getUserCategoryWeights(int userId) async {
    final db = await database;
    final rows = await db.query(
      interactionsTable,
      columns: ['categories'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    final weights = <String, int>{};

    for (final row in rows) {
      final rawCategories = _normalizeCategories(
        (row['categories'] as String? ?? '')
            .split(',')
            .map((category) => category.trim().toLowerCase())
            .toList(),
        lowerCase: true,
      );

      for (final category in rawCategories) {
        weights[category] = (weights[category] ?? 0) + 1;
      }
    }

    return weights;
  }

  Future<void> clearAnimeInteractions() async {
    final db = await database;
    await db.delete(interactionsTable);
  }

  Future<void> saveActiveCategories(List<String> categories) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _activeCategoriesKey,
      _normalizeCategories(categories),
    );
  }

  Future<List<String>> getActiveCategories() async {
    final preferences = await SharedPreferences.getInstance();
    return _normalizeCategories(
      preferences.getStringList(_activeCategoriesKey) ?? <String>[],
    );
  }

  Future<void> clearActiveCategories() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_activeCategoriesKey);
  }

  Future<void> updateRecommendationImageUrl({
    required String title,
    required String imageUrl,
  }) async {
    final db = await database;
    await db.update(
      animeTable,
      {'image_url': imageUrl},
      where: 'title = ?',
      whereArgs: [title],
    );
  }

  static List<String> _normalizeCategories(
    List<String> categories, {
    bool lowerCase = false,
    int limit = _maxStoredCategories,
  }) {
    final normalizedCategories = <String>[];
    final seenCategories = <String>{};

    for (final category in categories) {
      final trimmedCategory = category.trim();

      if (trimmedCategory.isEmpty) {
        continue;
      }

      final normalizedCategory = lowerCase
          ? trimmedCategory.toLowerCase()
          : trimmedCategory;
      final categoryKey = normalizedCategory.toLowerCase();

      if (seenCategories.add(categoryKey)) {
        normalizedCategories.add(normalizedCategory);
      }

      if (normalizedCategories.length >= limit) {
        break;
      }
    }

    return normalizedCategories;
  }

  static final List<RecommendationAnime> _seedRecommendations = [
    RecommendationAnime(
      id: 101,
      title: 'Attack on Titan',
      synopsis:
          'A dark action story about humanity fighting for survival against gigantic titans.',
      categories: const ['Action', 'Drama', 'Fantasy', 'Mystery'],
      score: 9.0,
      imageUrl: 'https://myanimelist.net/images/anime/10/47347.jpg',
    ),
    RecommendationAnime(
      id: 102,
      title: 'Demon Slayer',
      synopsis:
          'A heartfelt action adventure about a boy trying to save his sister and end the demon threat.',
      categories: const ['Action', 'Adventure', 'Fantasy', 'Supernatural'],
      score: 8.8,
      imageUrl: 'https://myanimelist.net/images/anime/1286/99889.jpg',
    ),
    RecommendationAnime(
      id: 103,
      title: 'Spy x Family',
      synopsis:
          'A spy, an assassin, and a telepathic child pretend to be a family in a charming comedy.',
      categories: const ['Comedy', 'Action', 'Slice of Life'],
      score: 8.6,
      imageUrl: 'https://myanimelist.net/images/anime/1441/122795.jpg',
    ),
    RecommendationAnime(
      id: 104,
      title: 'Your Name',
      synopsis:
          'Two teenagers mysteriously swap bodies and build a powerful connection across time and distance.',
      categories: const ['Romance', 'Drama', 'Supernatural'],
      score: 8.9,
      imageUrl: 'https://myanimelist.net/images/anime/5/87048.jpg',
    ),
    RecommendationAnime(
      id: 105,
      title: 'Steins;Gate',
      synopsis:
          'A sci-fi thriller where a group of friends discovers a way to alter the past.',
      categories: const ['Sci-Fi', 'Drama', 'Mystery'],
      score: 9.1,
      imageUrl: 'https://myanimelist.net/images/anime/1935/127974.jpg',
    ),
    RecommendationAnime(
      id: 106,
      title: 'Frieren: Beyond Journey\'s End',
      synopsis:
          'An emotional fantasy journey that follows an elf mage reflecting on time, memory, and companionship.',
      categories: const ['Fantasy', 'Drama', 'Adventure'],
      score: 9.3,
      imageUrl: null,
    ),
    RecommendationAnime(
      id: 107,
      title: 'Kaguya-sama: Love Is War',
      synopsis:
          'Two brilliant students turn romance into a hilarious battle of pride and strategy.',
      categories: const ['Comedy', 'Romance', 'Slice of Life'],
      score: 8.7,
      imageUrl: null,
    ),
    RecommendationAnime(
      id: 108,
      title: 'One Piece',
      synopsis:
          'A sprawling pirate adventure focused on freedom, friendship, and the pursuit of the ultimate treasure.',
      categories: const ['Action', 'Adventure', 'Comedy', 'Fantasy'],
      score: 9.2,
      imageUrl: null,
    ),
    RecommendationAnime(
      id: 109,
      title: 'Violet Evergarden',
      synopsis:
          'A moving drama about a former soldier learning how to understand human emotion through letters.',
      categories: const ['Drama', 'Slice of Life', 'Fantasy'],
      score: 8.9,
      imageUrl: null,
    ),
    RecommendationAnime(
      id: 110,
      title: 'Jujutsu Kaisen',
      synopsis:
          'A high-energy supernatural action series centered on cursed energy and intense battles.',
      categories: const ['Action', 'Supernatural', 'Mystery'],
      score: 8.8,
      imageUrl: null,
    ),
    RecommendationAnime(
      id: 111,
      title: 'Made in Abyss',
      synopsis:
          'A fantasy adventure that begins with wonder and quickly becomes haunting and emotional.',
      categories: const ['Fantasy', 'Adventure', 'Drama', 'Mystery'],
      score: 8.6,
      imageUrl: 'https://myanimelist.net/images/anime/6/86733.jpg',
    ),
    RecommendationAnime(
      id: 112,
      title: 'Horimiya',
      synopsis:
          'A warm romance and slice-of-life story about two students discovering each other\'s hidden sides.',
      categories: const ['Romance', 'Slice of Life', 'Comedy'],
      score: 8.4,
      imageUrl: null,
    ),
    RecommendationAnime(
      id: 113,
      title: 'Haikyuu!!',
      synopsis:
          'A fast-paced sports series about a volleyball team chasing growth, teamwork, and big wins.',
      categories: const ['Sports', 'Comedy', 'Drama'],
      score: 8.9,
      imageUrl: null,
    ),
    RecommendationAnime(
      id: 114,
      title: 'Naruto',
      synopsis:
          'A classic ninja adventure following a determined outcast who wants recognition and strength.',
      categories: const ['Action', 'Adventure', 'Fantasy'],
      score: 8.0,
      imageUrl: null,
    ),
    RecommendationAnime(
      id: 115,
      title: 'Fullmetal Alchemist: Brotherhood',
      synopsis:
          'Two brothers search for a way to restore what they lost after a forbidden alchemy ritual.',
      categories: const ['Action', 'Adventure', 'Drama', 'Fantasy'],
      score: 9.2,
      imageUrl: null,
    ),
    RecommendationAnime(
      id: 116,
      title: 'Death Note',
      synopsis:
          'A psychological thriller about a student who gains the power to decide who lives and dies.',
      categories: const ['Mystery', 'Supernatural', 'Drama'],
      score: 8.6,
      imageUrl: null,
    ),
    RecommendationAnime(
      id: 117,
      title: 'Tokyo Ghoul',
      synopsis:
          'A dark fantasy about a college student pulled into the brutal hidden world of ghouls.',
      categories: const ['Action', 'Horror', 'Drama'],
      score: 7.8,
      imageUrl: null,
    ),
    RecommendationAnime(
      id: 118,
      title: 'Mob Psycho 100',
      synopsis:
          'A psychic middle schooler tries to live a normal life while chaos keeps finding him.',
      categories: const ['Action', 'Comedy', 'Supernatural'],
      score: 8.8,
      imageUrl: null,
    ),
    RecommendationAnime(
      id: 119,
      title: 'Blue Lock',
      synopsis:
          'A ruthless soccer training project designed to create the world\'s best striker.',
      categories: const ['Sports', 'Action', 'Drama'],
      score: 8.1,
      imageUrl: null,
    ),
    RecommendationAnime(
      id: 120,
      title: 'Chainsaw Man',
      synopsis:
          'A chaotic devil-hunting story about survival, strange friendships, and impossible odds.',
      categories: const ['Action', 'Supernatural', 'Horror'],
      score: 8.5,
      imageUrl: null,
    ),
  ];
}
