import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/anime_model.dart';

class AnimeCard extends StatelessWidget {
  final Anime anime;
  final VoidCallback onTap;

  const AnimeCard({
    Key? key,
    required this.anime,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        color: colorScheme.surface,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colorScheme.outline,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Anime Image
              SizedBox(
                width: 100,
                height: 140,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    bottomLeft: Radius.circular(22),
                  ),
                  child: anime.image != null && anime.image!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: anime.image!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        anime.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Rating and Episodes Row
                      Row(
                        children: [
                          // Rating
                          if (anime.score != null && anime.score! > 0)
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: colorScheme.secondary,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  anime.score!.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: colorScheme.secondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(width: 12),
                          // Episodes
                          if (anime.episodes != null && anime.episodes! > 0)
                            Row(
                              children: [
                                Icon(
                                  Icons.play_circle_outline,
                                  color: colorScheme.primary,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${anime.episodes} ep',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Status
                      if (anime.status != null && anime.status!.isNotEmpty)
                        Text(
                          anime.status!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Synopsis Preview
                      if (anime.synopsis != null && anime.synopsis!.isNotEmpty)
                        Text(
                          anime.synopsis!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
