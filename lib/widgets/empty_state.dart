import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData icon;

  const EmptyState({
    Key? key,
    required this.message,
    this.subtitle,
    this.icon = Icons.search,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.45),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 44,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
