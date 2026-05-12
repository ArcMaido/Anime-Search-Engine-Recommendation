import '../models/recommendation_anime.dart';
import 'anime_service.dart';
import 'app_database.dart';

class RecommendationService {
  static final Map<String, Future<String?>> _posterCache = {};

  static Future<List<RecommendationAnime>> getRecommendations(
    int userId,
    List<String> selectedCategories, {
    int limit = 30,
  }) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(AppDatabase.animeTable);
    final interactionWeights = await AppDatabase.instance.getUserCategoryWeights(userId);

    final normalizedSelections = selectedCategories
        .map((category) => category.trim().toLowerCase())
        .toSet();

    final recommendations = rows
        .map((row) => RecommendationAnime.fromMap(row))
        .map((anime) {
          final weightedMatchCount = anime.categories.fold<int>(0, (
            int total,
            String category,
          ) {
            final normalizedCategory = category.toLowerCase();
            final selectionBoost =
                normalizedSelections.contains(normalizedCategory) ? 3 : 0;
            final interactionBoost = interactionWeights[normalizedCategory] ?? 0;
            return total + selectionBoost + interactionBoost;
          });

          return anime.copyWith(matchCount: weightedMatchCount);
        })
        .toList()
      ..sort((left, right) {
        final hasSelections = normalizedSelections.isNotEmpty || interactionWeights.isNotEmpty;

        if (!hasSelections) {
          return right.score.compareTo(left.score);
        }

        final matchCompare = right.matchCount.compareTo(left.matchCount);
        if (matchCompare != 0) {
          return matchCompare;
        }

        return right.score.compareTo(left.score);
      });

    final hasSelections = normalizedSelections.isNotEmpty || interactionWeights.isNotEmpty;
    final filteredRecommendations = hasSelections
        ? recommendations.where((anime) => anime.matchCount > 0).toList()
        : recommendations;

    final limitedRecommendations = filteredRecommendations.take(limit).toList();
    final hydratedRecommendations = await Future.wait(
      limitedRecommendations.map(_hydratePosterImage),
    );

    return hydratedRecommendations;
  }

  static Future<RecommendationAnime> _hydratePosterImage(
    RecommendationAnime anime,
  ) async {
    if (anime.imageUrl != null && anime.imageUrl!.isNotEmpty) {
      return anime;
    }

    final posterUrl = await _posterCache.putIfAbsent(
      anime.title,
      () async {
        try {
          final response = await AnimeService.searchAnime(anime.title);
          final match = response.data.isEmpty
              ? null
              : response.data.firstWhere(
                  (item) => item.title.toLowerCase() == anime.title.toLowerCase(),
                  orElse: () => response.data.first,
                );
          final candidate = match;
          final imageUrl = candidate?.image;

          if (imageUrl != null && imageUrl.isNotEmpty) {
            await AppDatabase.instance.updateRecommendationImageUrl(
              title: anime.title,
              imageUrl: imageUrl,
            );
          }

          return imageUrl;
        } catch (_) {
          return null;
        }
      },
    );

    return RecommendationAnime(
      id: anime.id,
      title: anime.title,
      synopsis: anime.synopsis,
      imageUrl: posterUrl,
      categories: anime.categories,
      score: anime.score,
      matchCount: anime.matchCount,
    );
  }
}
