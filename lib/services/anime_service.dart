import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/anime_model.dart';

class AnimeService {
  static const String baseUrl = 'https://api.jikan.moe/v4';
  static const int timeoutSeconds = 15;

  /// Search for anime by query
  static Future<AnimeResponse> searchAnime(String query, {int page = 1}) async {
    try {
      if (query.isEmpty) {
        return AnimeResponse(data: [], pagination: Pagination(lastVisiblePage: 1, hasNextPage: false));
      }

      final String url = '$baseUrl/anime?q=$query&page=$page&limit=25';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: timeoutSeconds),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return AnimeResponse.fromJson(json);
      } else if (response.statusCode == 404) {
        return AnimeResponse(data: [], pagination: Pagination(lastVisiblePage: 1, hasNextPage: false));
      } else {
        throw Exception('Failed to load anime: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  /// Get anime detail by ID
  static Future<Anime?> getAnimeDetail(int malId) async {
    try {
      final String url = '$baseUrl/anime/$malId/full';
      
      final response = await http.get(
        Uri.parse(url),
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
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }
}
