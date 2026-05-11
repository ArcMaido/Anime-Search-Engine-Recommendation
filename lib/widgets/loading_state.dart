import 'package:flutter/material.dart';

class LoadingState extends StatelessWidget {
  final String? message;

  const LoadingState({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            strokeWidth: 3,
          ),
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                message!,
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
