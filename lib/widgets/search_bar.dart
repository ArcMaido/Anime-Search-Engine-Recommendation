import 'package:flutter/material.dart';

class AnimeSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function(String)? onChanged;
  final bool isLoading;

  const AnimeSearchBar({
    Key? key,
    required this.onSearch,
    this.onChanged,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<AnimeSearchBar> createState() => _AnimeSearchBarState();
}

class _AnimeSearchBarState extends State<AnimeSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasText = _controller.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerHighest.withOpacity(0.55),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasText ? colorScheme.primary : colorScheme.outline,
            width: hasText ? 1.2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          textInputAction: TextInputAction.search,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          onChanged: (value) {
            setState(() {});
            widget.onChanged?.call(value);
          },
          onSubmitted: widget.onSearch,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Search anime title, genre, mood',
            prefixIcon: Icon(Icons.travel_explore_rounded, color: colorScheme.primary),
            suffixIcon: widget.isLoading
                ? Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : hasText
                    ? IconButton(
                        tooltip: 'Clear search',
                        icon: Icon(Icons.close_rounded, color: colorScheme.primary),
                        onPressed: () {
                          setState(_controller.clear);
                          widget.onChanged?.call('');
                        },
                      )
                    : null,
          ),
        ),
      ),
    );
  }
}
