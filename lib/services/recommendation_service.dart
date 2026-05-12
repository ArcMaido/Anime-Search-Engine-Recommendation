import '../models/recommendation_anime.dart';
import 'anime_service.dart';
import 'app_database.dart';

class RecommendationService {
  static final Map<String, Future<RecommendationAnime?>> _detailCache = {};

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
      limitedRecommendations.map(_hydrateRecommendation),
    );

    return hydratedRecommendations.whereType<RecommendationAnime>().toList();
  }

  static Future<RecommendationAnime?> _hydrateRecommendation(
    RecommendationAnime anime,
  ) async {
    return _detailCache.putIfAbsent(anime.title, () async {
      try {
        final searchResult = await AnimeService.searchAnime(anime.title);
        if (searchResult.data.isEmpty) {
          return anime;
        }

        final matchedAnime = searchResult.data.firstWhere(
          (item) => item.title.toLowerCase() == anime.title.toLowerCase(),
          orElse: () => searchResult.data.first,
        );

        final detail = await AnimeService.getAnimeDetail(matchedAnime.malId);
        final resolvedAnime = detail ?? matchedAnime;
        final imageUrl = resolvedAnime.image;

        if (imageUrl != null && imageUrl.isNotEmpty) {
          await AppDatabase.instance.updateRecommendationImageUrl(
            title: anime.title,
            imageUrl: imageUrl,
          );
        }

        return anime.copyWith(
          synopsis: resolvedAnime.synopsis,
          imageUrl: imageUrl,
          episodes: resolvedAnime.episodes,
          status: resolvedAnime.status,
          rank: resolvedAnime.rank,
          popularity: resolvedAnime.popularity,
        );
      } catch (_) {
        return anime;
      }
    });
  }

  /// Get recommendations by matching categories, sorted A-Z by title
  static Future<List<RecommendationAnime>> getRecommendationsByCategories(
    List<String> targetCategories, {
    int limit = 30,
  }) async {
    if (targetCategories.isEmpty) {
      return [];
    }

    final db = await AppDatabase.instance.database;
    final rows = await db.query(AppDatabase.animeTable);

    final normalizedTargetCategories = targetCategories
        .map((category) => category.trim().toLowerCase())
        .toSet();

    final matchingAnime = rows
        .map((row) => RecommendationAnime.fromMap(row))
        .where((anime) {
          final animeCategories = anime.categories
              .map((cat) => cat.trim().toLowerCase())
              .toSet();
          return animeCategories.any(
            (cat) => normalizedTargetCategories.contains(cat),
          );
        })
        .toList()
      ..sort((a, b) => a.title.compareTo(b.title)); // Sort A-Z

    final limitedAnime = matchingAnime.take(limit).toList();
    final hydratedAnime = await Future.wait(
      limitedAnime.map(_hydrateRecommendation),
    );

    return hydratedAnime.whereType<RecommendationAnime>().toList();
  }
}
