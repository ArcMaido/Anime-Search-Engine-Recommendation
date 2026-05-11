import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/recommendation_anime.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String _databaseName = 'searchnime.db';
  static const int _databaseVersion = 3;

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
      batch.insert(animeTable, {
        'id': anime.id,
        'title': anime.title,
        'synopsis': anime.synopsis,
        'image_url': anime.imageUrl,
        'categories': anime.categories.join(', '),
        'score': anime.score,
      });
    }

    await batch.commit(noResult: true);
  }

  Future<void> saveAnimeInteraction({
    required int userId,
    required int animeId,
    required String animeTitle,
    required List<String> categories,
  }) async {
    if (categories.isEmpty) {
      return;
    }

    final db = await database;
    await db.insert(interactionsTable, {
      'user_id': userId,
      'anime_id': animeId,
      'anime_title': animeTitle,
      'categories': categories.join(', '),
      'created_at': DateTime.now().toIso8601String(),
    });
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
      final rawCategories = (row['categories'] as String? ?? '')
          .split(',')
          .map((category) => category.trim().toLowerCase())
          .where((category) => category.isNotEmpty);

      for (final category in rawCategories) {
        weights[category] = (weights[category] ?? 0) + 1;
      }
    }

    return weights;
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
      imageUrl: _posterPlaceholder('Frieren: Beyond Journey\'s End'),
    ),
    RecommendationAnime(
      id: 107,
      title: 'Kaguya-sama: Love Is War',
      synopsis:
          'Two brilliant students turn romance into a hilarious battle of pride and strategy.',
      categories: const ['Comedy', 'Romance', 'Slice of Life'],
      score: 8.7,
      imageUrl: _posterPlaceholder('Kaguya-sama: Love Is War'),
    ),
    RecommendationAnime(
      id: 108,
      title: 'One Piece',
      synopsis:
          'A sprawling pirate adventure focused on freedom, friendship, and the pursuit of the ultimate treasure.',
      categories: const ['Action', 'Adventure', 'Comedy', 'Fantasy'],
      score: 9.2,
      imageUrl: _posterPlaceholder('One Piece'),
    ),
    RecommendationAnime(
      id: 109,
      title: 'Violet Evergarden',
      synopsis:
          'A moving drama about a former soldier learning how to understand human emotion through letters.',
      categories: const ['Drama', 'Slice of Life', 'Fantasy'],
      score: 8.9,
      imageUrl: _posterPlaceholder('Violet Evergarden'),
    ),
    RecommendationAnime(
      id: 110,
      title: 'Jujutsu Kaisen',
      synopsis:
          'A high-energy supernatural action series centered on cursed energy and intense battles.',
      categories: const ['Action', 'Supernatural', 'Mystery'],
      score: 8.8,
      imageUrl: _posterPlaceholder('Jujutsu Kaisen'),
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
      imageUrl: _posterPlaceholder('Horimiya'),
    ),
  ];

  static String _posterPlaceholder(String title) {
    return 'https://placehold.co/400x600/0f172a/f8fafc?text=${Uri.encodeComponent(title)}';
  }
}
