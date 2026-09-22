import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.terracotta,
      brightness: brightness,
    ).copyWith(
      primary: dark ? AppColors.peach : AppColors.terracotta,
      onPrimary: dark ? const Color(0xFF442013) : Colors.white,
      primaryContainer:
          dark ? const Color(0xFF573124) : const Color(0xFFF5D9CA),
      onPrimaryContainer:
          dark ? const Color(0xFFFFDBCB) : const Color(0xFF572716),
      secondary: dark ? const Color(0xFFDAC4A4) : const Color(0xFF725B3E),
      onSecondary: dark ? const Color(0xFF3A2D1B) : Colors.white,
      secondaryContainer:
          dark ? const Color(0xFF493B2D) : const Color(0xFFEADDCB),
      onSecondaryContainer:
          dark ? const Color(0xFFF2E1C9) : const Color(0xFF403224),
      surface: dark ? AppColors.nightSurface : AppColors.cream,
      onSurface: dark ? const Color(0xFFF1E6DC) : AppColors.ink,
      onSurfaceVariant:
          dark ? const Color(0xFFD0BDB0) : const Color(0xFF6E5D52),
      surfaceContainerHighest:
          dark ? const Color(0xFF40342D) : const Color(0xFFEDE2D5),
      outline: dark ? const Color(0xFFA38D7E) : const Color(0xFF8A7565),
      outlineVariant: dark ? const Color(0xFF56463B) : const Color(0xFFD9C9B9),
    );
    final background = dark ? AppColors.night : AppColors.sand;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: scheme.primary.withAlpha(52),
        selectionHandleColor: scheme.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: shape,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(64, 48),
          shape: shape,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: shape,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color:
                states.contains(WidgetState.selected)
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color:
                states.contains(WidgetState.selected)
                    ? scheme.onSurface
                    : scheme.onSurfaceVariant,
            fontWeight:
                states.contains(WidgetState.selected)
                    ? FontWeight.w700
                    : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape: shape,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
    );
  }
}
