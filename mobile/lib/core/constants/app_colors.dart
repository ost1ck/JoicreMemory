import 'package:flutter/material.dart';

/// Brand colors. UI components should use Theme.of(context).colorScheme.
abstract final class AppColors {
  static const sand = Color(0xFFF5EFE6);
  static const cream = Color(0xFFFFFBF5);
  static const terracotta = Color(0xFFA3442D);
  static const peach = Color(0xFFF1A68B);
  static const ink = Color(0xFF30251F);
  static const night = Color(0xFF201A17);
  static const nightSurface = Color(0xFF2B231F);

  // Distinct data visualization colors, not theme accents.
  static const leaf = Color(0xFF557C52);
  static const sky = Color(0xFF547F9B);
  static const coral = Color(0xFFBE674D);
  static const sun = Color(0xFFB58A37);
  static const teal = Color(0xFF548A83);
  static const berry = Color(0xFF907099);
}
