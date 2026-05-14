import '../models/recommendation_anime.dart';
import 'anime_service.dart';
import 'app_database.dart';

class RecommendationService {
  static final Map<String, Future<RecommendationAnime?>> _detailCache = {};
  static const int _maxCategoryCount = 10;

  static Future<List<RecommendationAnime>> getRecommendations(
    int userId,
    List<String> selectedCategories, {
    int limit = 30,
  }) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(AppDatabase.animeTable);
    final interactionWeights = await AppDatabase.instance.getUserCategoryWeights(userId);

    final normalizedSelections = _normalizeCategories(selectedCategories)
      .map((category) => category.toLowerCase())
        .toSet();

    final recommendations = rows
        .map((row) => RecommendationAnime.fromMap(row))
        .map((anime) {
          final weightedMatchCount = anime.categories.fold<int>(0, (
            int total,
            String category,
          ) {
            final normalizedCategory = category.trim().toLowerCase();
            final selectionBoost =
                normalizedSelections.contains(normalizedCategory) ? 3 : 0;
            final interactionBoost = interactionWeights[normalizedCategory] ?? 0;
            return total + selectionBoost + interactionBoost;
          });

          return anime.copyWith(matchCount: weightedMatchCount);
        })
        .toList()
      ..sort(_compareRecommendations);

    final hasSelections = normalizedSelections.isNotEmpty || interactionWeights.isNotEmpty;
    final filteredRecommendations = hasSelections
        ? recommendations.where((anime) => anime.matchCount > 0).toList()
        : recommendations;

    final limitedRecommendations = filteredRecommendations.take(limit).toList();
    final hydratedRecommendations = await Future.wait(
      limitedRecommendations.map(_hydrateRecommendation),
    );

    return _sortByRelevance(
      hydratedRecommendations.whereType<RecommendationAnime>().toList(),
    );
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

  /// Get recommendations by matching categories, ranked by relevance.
  static Future<List<RecommendationAnime>> getRecommendationsByCategories(
    List<String> targetCategories, {
    int limit = 30,
  }) async {
    if (targetCategories.isEmpty) {
      return [];
    }

    final db = await AppDatabase.instance.database;
    final rows = await db.query(AppDatabase.animeTable);

    final normalizedTargetCategories = _normalizeCategories(targetCategories)
        .map((category) => category.toLowerCase())
        .toSet();

    final matchingAnime = rows
        .map((row) => RecommendationAnime.fromMap(row))
        .map((anime) {
          final matchCount = anime.categories.where((category) {
            return normalizedTargetCategories.contains(
              category.trim().toLowerCase(),
            );
          }).length;

          if (matchCount == 0) {
            return null;
          }

          return anime.copyWith(matchCount: matchCount);
        })
        .whereType<RecommendationAnime>()
        .toList()
      ..sort(_compareRecommendations);

    final limitedAnime = matchingAnime.take(limit).toList();
    final hydratedAnime = await Future.wait(
      limitedAnime.map(_hydrateRecommendation),
    );

    return _sortByRelevance(
      hydratedAnime.whereType<RecommendationAnime>().toList(),
    );
  }

  static List<String> _normalizeCategories(
    List<String> categories, {
    int limit = _maxCategoryCount,
  }) {
    final normalizedCategories = <String>[];
    final seenCategories = <String>{};

    for (final category in categories) {
      final trimmedCategory = category.trim();

      if (trimmedCategory.isEmpty) {
        continue;
      }

      final categoryKey = trimmedCategory.toLowerCase();
      if (seenCategories.add(categoryKey)) {
        normalizedCategories.add(trimmedCategory);
      }

      if (normalizedCategories.length >= limit) {
        break;
      }
    }

    return normalizedCategories;
  }

  static int _compareRecommendations(
    RecommendationAnime left,
    RecommendationAnime right,
  ) {
    final matchCompare = right.matchCount.compareTo(left.matchCount);
    if (matchCompare != 0) {
      return matchCompare;
    }

    final scoreCompare = right.score.compareTo(left.score);
    if (scoreCompare != 0) {
      return scoreCompare;
    }

    final leftPopularity = left.popularity ?? 0;
    final rightPopularity = right.popularity ?? 0;
    final popularityCompare = leftPopularity.compareTo(rightPopularity);
    if (popularityCompare != 0) {
      return popularityCompare;
    }

    return left.title.toLowerCase().compareTo(right.title.toLowerCase());
  }

  static List<RecommendationAnime> _sortByRelevance(
    List<RecommendationAnime> animeList,
  ) {
    final sortedList = List<RecommendationAnime>.from(animeList);
    sortedList.sort(_compareRecommendations);
    return sortedList;
  }
}
