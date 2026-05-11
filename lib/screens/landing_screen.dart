import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/theme_toggle_button.dart';
import 'home_screen.dart';

class LandingScreen extends StatefulWidget {
  final AppUser user;

  const LandingScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  static const List<String> _categories = [
    'Action',
    'Adventure',
    'Comedy',
    'Drama',
    'Fantasy',
    'Romance',
    'Sci-Fi',
    'Slice of Life',
    'Supernatural',
    'Mystery',
  ];

  final Set<String> _selectedCategories = {};
  bool _isLoading = false;

  Future<void> _openRecommendation() async {
    if (_selectedCategories.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 3 categories.'),
        ),
      );
      return;
    }

    await AuthService.completeOnboarding(widget.user.id);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          user: widget.user,
          selectedCategories: _selectedCategories.toList(),
        ),
      ),
      (route) => false,
    );
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
        return;
      }

      _selectedCategories.add(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SearchNime',
                          style: TextStyle(
                            color: colorScheme.onBackground,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pick 3 or more categories and jump straight into your personalized anime feed.',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const ThemeToggleButton(),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withOpacity(0.95),
                      colorScheme.secondary.withOpacity(0.88),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Build your feed',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose categories that match your taste. Your search page will open with anime recommendations already prepared for you.',
                      style: TextStyle(
                        color: colorScheme.onPrimary.withOpacity(0.95),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Select categories',
                style: TextStyle(
                  color: colorScheme.onBackground,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Minimum of 3 categories required.',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categories.map((category) {
                  final isSelected = _selectedCategories.contains(category);
                  return FilterChip(
                    selected: isSelected,
                    label: Text(category),
                    onSelected: (_) => _toggleCategory(category),
                    selectedColor: AppTheme.primaryPurple.withOpacity(0.22),
                    checkmarkColor: AppTheme.accentCyan,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outline,
                    ),
                    backgroundColor: colorScheme.surface,
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tune, color: colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Selected categories: ${_selectedCategories.length}',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedCategories.length >= 3
                      ? _openRecommendation
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Continue to Recommendations',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
