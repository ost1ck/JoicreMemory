import 'package:flutter/material.dart';

abstract final class AppGradients {
  static LinearGradient accent(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors:
          dark
              ? [
                colors.primary,
                const Color(0xFFDC9277),
                const Color(0xFFF6C9A8),
              ]
              : [
                const Color(0xFF84372B),
                colors.primary,
                const Color(0xFFAB5436),
              ],
    );
  }

  static LinearGradient surface(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colors.surface,
        Color.lerp(colors.surface, colors.primaryContainer, .32)!,
      ],
    );
  }
}
