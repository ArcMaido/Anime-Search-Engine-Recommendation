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

  const DetailScreen({
    Key? key,
    required this.anime,
    this.loadFromApi = false,
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
    if (!widget.loadFromApi) {
      return;
    }

    final searchResult = await AnimeService.searchAnime(_anime.title);
    if (!mounted || searchResult.data.isEmpty) {
      return;
    }

    final matchedAnime = searchResult.data.firstWhere(
      (item) => item.title.toLowerCase() == _anime.title.toLowerCase(),
      orElse: () => searchResult.data.first,
    );

    final detail = await AnimeService.getAnimeDetail(matchedAnime.malId);
    final resolvedAnime = detail ?? matchedAnime;

    setState(() {
      _anime = resolvedAnime;
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
            expandedHeight: 300,
            pinned: true,
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
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Anime Image
                  if (_anime.image != null && _anime.image!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: _anime.image!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: colorScheme.surface,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: colorScheme.surface,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppTheme.greyText,
                            size: 48,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      color: colorScheme.surface,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppTheme.greyText,
                          size: 48,
                        ),
                      ),
                    ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          colorScheme.background.withOpacity(0.7),
                          colorScheme.background,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _anime.title,
                    style: TextStyle(
                      color: colorScheme.onBackground,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Score, Rank, Popularity Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (_anime.score != null && _anime.score! > 0)
                          _buildInfoChip(
                            context: context,
                            icon: Icons.star,
                            label: 'Score',
                            value: _anime.score!.toStringAsFixed(1),
                          ),
                        const SizedBox(width: 12),
                        if (_anime.rank != null && _anime.rank! > 0)
                          _buildInfoChip(
                            context: context,
                            icon: Icons.trending_up,
                            label: 'Rank',
                            value: '#${_anime.rank}',
                          ),
                        const SizedBox(width: 12),
                        if (_anime.popularity != null && _anime.popularity! > 0)
                          _buildInfoChip(
                            context: context,
                            icon: Icons.favorite,
                            label: 'Popularity',
                            value: '#${_anime.popularity}',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Episodes and Status
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Episodes',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _anime.episodes?.toString() ?? 'N/A',
                              style: TextStyle(
                                color: AppTheme.accentCyan,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _anime.status ?? 'N/A',
                              style: TextStyle(
                                color: AppTheme.primaryPurple,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Genres
                  if (_anime.genres != null && _anime.genres!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Genres',
                          style: TextStyle(
                            color: colorScheme.onBackground,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Synopsis
                  if (_anime.synopsis != null && _anime.synopsis!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          _anime.synopsis!,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 15,
                            height: 1.75,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

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

  Widget _buildInfoChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
