import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/anime_model.dart';

class AnimeService {
  static const String baseUrl = 'https://api.jikan.moe/v4';
  static const int timeoutSeconds = 15;
  static final http.Client _client = http.Client();

  static final Map<String, AnimeResponse> _searchCache = {};
  static final Map<String, Future<AnimeResponse>> _searchInFlight = {};
  static final Map<int, Anime?> _detailCache = {};
  static final Map<int, Future<Anime?>> _detailInFlight = {};

  /// Search for anime by query
  static Future<AnimeResponse> searchAnime(String query, {int page = 1}) async {
    try {
      final trimmedQuery = query.trim();
      if (trimmedQuery.isEmpty) {
        return AnimeResponse(data: [], pagination: Pagination(lastVisiblePage: 1, hasNextPage: false));
      }

      final cacheKey = '${trimmedQuery.toLowerCase()}::$page';
      final cached = _searchCache[cacheKey];
      if (cached != null) {
        return cached;
      }

      final inFlight = _searchInFlight[cacheKey];
      if (inFlight != null) {
        return inFlight;
      }

      final requestFuture = _executeSearch(trimmedQuery, page, cacheKey);
      _searchInFlight[cacheKey] = requestFuture;

      final result = await requestFuture;
      _searchInFlight.remove(cacheKey);
      return result;
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  static Future<AnimeResponse> _executeSearch(
    String query,
    int page,
    String cacheKey,
  ) async {
    final uri = Uri.parse('$baseUrl/anime').replace(
      queryParameters: {
        'q': query,
        'page': '$page',
        'limit': '25',
      },
    );

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    ).timeout(
      const Duration(seconds: timeoutSeconds),
      onTimeout: () => throw Exception('Request timeout'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final parsed = AnimeResponse.fromJson(json);
      _searchCache[cacheKey] = parsed;
      return parsed;
    }

    if (response.statusCode == 404) {
      final empty = AnimeResponse(
        data: [],
        pagination: Pagination(lastVisiblePage: 1, hasNextPage: false),
      );
      _searchCache[cacheKey] = empty;
      return empty;
    }

    throw Exception('Failed to load anime: ${response.statusCode}');
  }

  /// Get anime detail by ID
  static Future<Anime?> getAnimeDetail(int malId) async {
    try {
      if (_detailCache.containsKey(malId)) {
        return _detailCache[malId];
      }

      final inFlight = _detailInFlight[malId];
      if (inFlight != null) {
        return inFlight;
      }

      final requestFuture = _executeDetail(malId);
      _detailInFlight[malId] = requestFuture;

      final result = await requestFuture;
      _detailInFlight.remove(malId);
      _detailCache[malId] = result;
      return result;
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  static Future<Anime?> _executeDetail(int malId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/anime/$malId/full'),
      headers: {
        'Content-Type': 'application/json',
      },
    ).timeout(
      const Duration(seconds: timeoutSeconds),
      onTimeout: () => throw Exception('Request timeout'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>?;
      if (data != null) {
        return Anime.fromJson(data);
      }
    }

    return null;
  }
}
