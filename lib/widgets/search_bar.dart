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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: colorScheme.outline.withOpacity(0.7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          style: TextStyle(color: colorScheme.onSurface, fontSize: 15),
          onChanged: (value) {
            setState(() {});
            widget.onChanged?.call(value);
          },
          onSubmitted: (value) {
            widget.onSearch(value);
          },
          decoration: InputDecoration(
            hintText: 'Search anime, studios, or genres',
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colorScheme.primary,
            ),
            suffixIcon: widget.isLoading
                ? Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.secondary,
                        ),
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: colorScheme.primary,
                        ),
                        onPressed: () {
                          setState(() {
                            _controller.clear();
                          });
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
