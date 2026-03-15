import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Modern Noir Brand ─────────────────────────────────────────
  static const Color neonMint = Color(0xFFCCFF00);
  static const Color deepCarbon = Color(0xFF080808);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Primary action = neon mint everywhere
  static const Color primary = neonMint;
  static const Color primaryForeground = deepCarbon;

  // ─── Dark theme ────────────────────────────────────────────────
  static const Color background = deepCarbon;
  static const Color surface = Color(0xFF111111);
  static const Color surfaceVariant = Color(0xFF191919);
  static const Color surfaceElevated = Color(0xFF222222);
  static const Color border = Color(0xFF222222);
  static const Color borderSubtle = Color(0xFF191919);

  static const Color textPrimary = pureWhite;
  static const Color textSecondary = Color(0xFF888888);
  static const Color textMuted = Color(0xFF444444);

  // ─── Light theme ───────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF8F8F8);
  static const Color surfaceLight = pureWhite;
  static const Color surfaceVariantLight = Color(0xFFF0F0F0);
  static const Color borderLight = Color(0xFFE0E0E0);

  static const Color textPrimaryLight = deepCarbon;
  static const Color textSecondaryLight = Color(0xFF666666);
  static const Color textMutedLight = Color(0xFF999999);

  // ─── Semantic ──────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ─── Score gradient ────────────────────────────────────────────
  static const Color scoreLow = Color(0xFFEF4444);
  static const Color scoreMid = Color(0xFFF59E0B);
  static const Color scoreHigh = Color(0xFF10B981);
}
