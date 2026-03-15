import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        scaffold: AppColors.background,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        textPrimary: AppColors.textPrimary,
        textSecondary: AppColors.textSecondary,
        fill: AppColors.surfaceVariant,
        borderColor: AppColors.border,
        hintColor: AppColors.textMuted,
        divider: AppColors.border,
        systemOverlay: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.background,
        ),
      );

  static ThemeData get light => _build(
        brightness: Brightness.light,
        scaffold: AppColors.backgroundLight,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        textPrimary: AppColors.textPrimaryLight,
        textSecondary: AppColors.textSecondaryLight,
        fill: AppColors.surfaceVariantLight,
        borderColor: AppColors.borderLight,
        hintColor: AppColors.textMutedLight,
        divider: AppColors.borderLight,
        systemOverlay: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.backgroundLight,
        ),
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color scaffold,
    required Color surface,
    required Color onSurface,
    required Color textPrimary,
    required Color textSecondary,
    required Color fill,
    required Color borderColor,
    required Color hintColor,
    required Color divider,
    required SystemUiOverlayStyle systemOverlay,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.neonMint,
      onPrimary: AppColors.deepCarbon,
      secondary: AppColors.neonMint,
      onSecondary: AppColors.deepCarbon,
      error: AppColors.error,
      onError: AppColors.pureWhite,
      surface: surface,
      onSurface: onSurface,
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
        centerTitle: false,
        systemOverlayStyle: systemOverlay,
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
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
          borderSide: const BorderSide(color: AppColors.neonMint, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: hintColor),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: hintColor),
        errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonMint,
          foregroundColor: AppColors.deepCarbon,
          disabledBackgroundColor:
              isDark ? const Color(0xFF2A2A2A) : const Color(0xFFDDDDDD),
          disabledForegroundColor:
              isDark ? const Color(0xFF555555) : const Color(0xFF999999),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTextStyles.labelLarge,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size(double.infinity, 52),
          side: BorderSide(color: borderColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.neonMint,
          textStyle: AppTextStyles.labelMedium,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      dividerTheme: DividerThemeData(color: divider, thickness: 1),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: AppColors.neonMint,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceVariant : AppColors.deepCarbon,
        contentTextStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.pureWhite),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) => TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: primary),
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
