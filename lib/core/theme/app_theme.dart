import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        scaffold: AppColors.background,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        textPrimary: AppColors.textPrimary,
        textSecondary: AppColors.textSecondary,
        fill: AppColors.surfaceVariant,
        borderColor: AppColors.border,
        hintColor: AppColors.textMuted,
        divider: AppColors.border,
      );

  static ThemeData get light => _build(
        brightness: Brightness.light,
        primary: AppColors.primary,
        scaffold: AppColors.backgroundLight,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        textPrimary: AppColors.textPrimaryLight,
        textSecondary: AppColors.textSecondaryLight,
        fill: AppColors.surfaceVariantLight,
        borderColor: AppColors.borderLight,
        hintColor: AppColors.textMutedLight,
        divider: AppColors.borderLight,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color scaffold,
    required Color surface,
    required Color onSurface,
    required Color textPrimary,
    required Color textSecondary,
    required Color fill,
    required Color borderColor,
    required Color hintColor,
    required Color divider,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: primary,
      surface: surface,
      onSurface: onSurface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: _textTheme(textPrimary, textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: textPrimary),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: hintColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppTextStyles.labelLarge,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(double.infinity, 52),
          side: BorderSide(color: borderColor),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      dividerTheme: DividerThemeData(color: divider, thickness: 1),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) => TextTheme(
        headlineLarge: AppTextStyles.headlineLarge.copyWith(color: primary),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: primary),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(color: primary),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: primary),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: primary),
        titleSmall: AppTextStyles.titleSmall.copyWith(color: primary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: primary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: primary),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: secondary),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: primary),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: primary),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: secondary),
      );
}
