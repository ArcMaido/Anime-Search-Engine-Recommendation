import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/anime_model.dart';
import '../services/anime_service.dart';
import '../services/favorites_service.dart';
import '../utils/app_theme.dart';
import '../widgets/genre_chip.dart';
import '../widgets/theme_toggle_button.dart';

class DetailScreen extends StatefulWidget {
  final Anime anime;
  final bool loadFromApi;
  final bool resolveByTitleFirst;

  const DetailScreen({
    Key? key,
    required this.anime,
    this.loadFromApi = false,
    this.resolveByTitleFirst = false,
  }) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Anime _anime;
  bool _isFavorite = false;
  bool _isFavoriteLoading = true;

  @override
  void initState() {
    super.initState();
    _anime = widget.anime;
    _loadFavoriteStatus();
    _loadAnimeDetailsIfNeeded();
  }

  Future<void> _loadAnimeDetailsIfNeeded() async {
    final needsApiRefresh = widget.loadFromApi ||
        _anime.episodes == null ||
        _anime.status == null ||
        _anime.synopsis == null ||
        _anime.synopsis!.trim().isEmpty;

    if (!needsApiRefresh) {
      return;
    }

    Anime? resolvedAnime;

    if (widget.resolveByTitleFirst) {
      final searchResult = await AnimeService.searchAnime(_anime.title);
      if (!mounted || searchResult.data.isEmpty) {
        return;
      }

      final matchedAnime = searchResult.data.firstWhere(
        (item) => item.title.toLowerCase() == _anime.title.toLowerCase(),
        orElse: () => searchResult.data.first,
      );
      resolvedAnime = await AnimeService.getAnimeDetail(matchedAnime.malId) ?? matchedAnime;
    } else {
      resolvedAnime = await AnimeService.getAnimeDetail(_anime.malId);

      if (resolvedAnime == null) {
        final searchResult = await AnimeService.searchAnime(_anime.title);
        if (!mounted || searchResult.data.isEmpty) {
          return;
        }

        final matchedAnime = searchResult.data.firstWhere(
          (item) => item.title.toLowerCase() == _anime.title.toLowerCase(),
          orElse: () => searchResult.data.first,
        );
        resolvedAnime =
            await AnimeService.getAnimeDetail(matchedAnime.malId) ?? matchedAnime;
      }
    }

    if (!mounted || resolvedAnime == null) {
      return;
    }

    final animeToDisplay = resolvedAnime;

    setState(() {
      _anime = animeToDisplay;
    });
  }

  Future<void> _loadFavoriteStatus() async {
    final isFavorite = await FavoritesService.isFavorite(_anime.malId);
    if (!mounted) {
      return;
    }

    setState(() {
      _isFavorite = isFavorite;
      _isFavoriteLoading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final isNowFavorite = await FavoritesService.toggleFavorite(_anime);
    if (!mounted) {
      return;
    }

    setState(() {
      _isFavorite = isNowFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowFavorite
              ? '${_anime.title} added to favorites'
              : '${_anime.title} removed from favorites',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            backgroundColor: colorScheme.background,
            elevation: 0,
            pinned: true,
            title: Text(
              _anime.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              const ThemeToggleButton(),
              IconButton(
                tooltip:
                    _isFavorite ? 'Remove from favorites' : 'Add to favorites',
                onPressed: _isFavoriteLoading ? null : _toggleFavorite,
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite
                      ? colorScheme.primary
                      : colorScheme.onBackground,
                ),
              ),
            ],
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colorScheme.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: AspectRatio(
                            aspectRatio: 3 / 4,
                            child: _anime.image != null && _anime.image!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: _anime.image!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: colorScheme.surfaceContainerHighest,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: colorScheme.surfaceContainerHighest,
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: AppTheme.greyText,
                                          size: 42,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: colorScheme.surfaceContainerHighest,
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: AppTheme.greyText,
                                        size: 42,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _anime.title,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (_anime.airing == true)
                              _buildBadge(
                                context,
                                icon: Icons.sensors_rounded,
                                text: 'Currently Airing',
                              ),
                            if (_anime.airing == false)
                              _buildBadge(
                                context,
                                icon: Icons.check_circle_outline,
                                text: 'Finished Airing',
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorScheme.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Information',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            if (_anime.score != null && _anime.score! > 0)
                              _buildInfoChip(
                                context: context,
                                icon: Icons.star_rounded,
                                label: 'Score',
                                value: _anime.score!.toStringAsFixed(1),
                              ),
                            if (_anime.rank != null && _anime.rank! > 0)
                              _buildInfoChip(
                                context: context,
                                icon: Icons.leaderboard_rounded,
                                label: 'Rank',
                                value: '#${_anime.rank}',
                              ),
                            if (_anime.popularity != null && _anime.popularity! > 0)
                              _buildInfoChip(
                                context: context,
                                icon: Icons.local_fire_department_rounded,
                                label: 'Popularity',
                                value: '#${_anime.popularity}',
                              ),
                            _buildInfoChip(
                              context: context,
                              icon: Icons.play_circle_outline,
                              label: 'Episodes',
                              value: _anime.episodes?.toString() ?? 'TBA',
                            ),
                            _buildInfoChip(
                              context: context,
                              icon: Icons.movie_filter_outlined,
                              label: 'Status',
                              value: _anime.status ?? 'TBA',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (_anime.genres != null && _anime.genres!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colorScheme.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Categories',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _anime.genres!
                                .map((genre) => GenreChip(label: genre.name))
                                .toList(),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  Text(
                    'Synopsis',
                    style: TextStyle(
                      color: colorScheme.onBackground,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    (_anime.synopsis != null && _anime.synopsis!.isNotEmpty)
                        ? _anime.synopsis!
                        : 'Synopsis is not available for this anime yet.',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 15,
                      height: 1.75,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Trailer
                  if (_anime.trailer != null &&
                      _anime.trailer!.youtubeId != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trailer',
                          style: TextStyle(
                            color: colorScheme.onBackground,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppTheme.cardBackground,
                          ),
                          child: InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Trailer URL available in app info',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.play_circle_filled,
                                    color: AppTheme.accentCyan,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Watch Trailer',
                                          style: TextStyle(
                                            color: colorScheme.onBackground,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _anime.trailer!.youtubeId ?? '',
                                          style: TextStyle(
                                            color: colorScheme.onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: AppTheme.primaryPurple,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.secondary.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.secondary),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.45),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.24),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: colorScheme.primary, size: 16),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
