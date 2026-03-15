import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary — electric violet
  static const Color primary = Color(0xFF6C3FF5);
  static const Color primaryLight = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF4C1D95);

  // Accent — neon lime for CTAs
  static const Color accent = Color(0xFFB5FF47);
  static const Color accentDark = Color(0xFF94D91F);

  // Score gradient colours
  static const Color scoreLow = Color(0xFFEF4444);   // < 4
  static const Color scoreMid = Color(0xFFF59E0B);   // 4–6
  static const Color scoreHigh = Color(0xFF10B981);  // 7+

  // Dark theme (default)
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF141414);
  static const Color surfaceVariant = Color(0xFF1E1E1E);
  static const Color surfaceElevated = Color(0xFF242424);
  static const Color border = Color(0xFF2C2C2C);
  static const Color borderSubtle = Color(0xFF1E1E1E);

  // Dark text
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF4B5563);

  // Light theme
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF3F4F6);
  static const Color borderLight = Color(0xFFE5E7EB);

  // Light text
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textMutedLight = Color(0xFF9CA3AF);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}
