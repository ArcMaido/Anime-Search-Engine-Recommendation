import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/anime_model.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_anime_list';

  static Future<List<Anime>> getFavorites() async {
    final preferences = await SharedPreferences.getInstance();
    final storedItems = preferences.getStringList(_favoritesKey) ?? <String>[];

    return storedItems
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .map(Anime.fromJson)
        .toList();
  }

  static Future<bool> isFavorite(int malId) async {
    final favorites = await getFavorites();
    return favorites.any((anime) => anime.malId == malId);
  }

  static Future<bool> toggleFavorite(Anime anime) async {
    final preferences = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    final existingIndex =
        favorites.indexWhere((item) => item.malId == anime.malId);

    if (existingIndex >= 0) {
      favorites.removeAt(existingIndex);
      await _saveFavorites(preferences, favorites);
      return false;
    }

    favorites.add(anime);
    await _saveFavorites(preferences, favorites);
    return true;
  }

  static Future<void> removeFavorite(int malId) async {
    final preferences = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.removeWhere((anime) => anime.malId == malId);
    await _saveFavorites(preferences, favorites);
  }

  static Future<void> _saveFavorites(
    SharedPreferences preferences,
    List<Anime> favorites,
  ) async {
    final encodedFavorites =
        favorites.map((anime) => jsonEncode(anime.toJson())).toList();

    await preferences.setStringList(_favoritesKey, encodedFavorites);
  }
}
