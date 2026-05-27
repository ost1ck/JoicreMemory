import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.leaf,
      brightness: Brightness.light,
      primary: AppColors.leaf,
      secondary: AppColors.coral,
      tertiary: AppColors.sun,
      surface: AppColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.mintCream,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.leaf,
        selectionColor: AppColors.leaf.withAlpha(52),
        selectionHandleColor: AppColors.leaf,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.mintCream,
        foregroundColor: AppColors.shadowGrey,
        centerTitle: false,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.shadowGrey,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFFF7FBF1),
        indicatorColor: const Color(0xFFCFF3D8),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color:
                states.contains(WidgetState.selected)
                    ? const Color(0xFF063B22)
                    : const Color(0xFF46524A),
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color:
                states.contains(WidgetState.selected)
                    ? AppColors.shadowGrey
                    : const Color(0xFF46524A),
            fontWeight:
                states.contains(WidgetState.selected)
                    ? FontWeight.w800
                    : FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.leaf,
      brightness: Brightness.dark,
      primary: const Color(0xFF7BE495),
      secondary: const Color(0xFFFF9A6E),
      tertiary: const Color(0xFFFFD166),
      surface: AppColors.nightSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.night,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorScheme.primary,
        selectionColor: colorScheme.primary.withAlpha(52),
        selectionHandleColor: colorScheme.primary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.night,
        foregroundColor: Color(0xFFFFF8F2),
        centerTitle: false,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF3C3037),
        labelStyle: const TextStyle(color: Color(0xFFD9C9D2)),
        hintStyle: const TextStyle(color: Color(0xFFBCAFB6)),
        prefixIconColor: const Color(0xFFD9C9D2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: AppColors.shadowGrey,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.nightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF132018),
        indicatorColor: const Color(0xFF315A40),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color:
                states.contains(WidgetState.selected)
                    ? const Color(0xFFD9FFE1)
                    : const Color(0xFFCAD8CE),
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color:
                states.contains(WidgetState.selected)
                    ? const Color(0xFFD9FFE1)
                    : const Color(0xFFCAD8CE),
            fontWeight:
                states.contains(WidgetState.selected)
                    ? FontWeight.w800
                    : FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
