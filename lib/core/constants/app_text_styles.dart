import 'package:flutter/material.dart';

// Space Grotesk font files live in assets/fonts/ (user provides TTF).
// Falls back to system sans-serif if font files are not yet present.
const String _kHeader = 'SpaceGrotesk';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _kHeader,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    height: 1.1,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _kHeader,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    height: 1.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _kHeader,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.25,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _kHeader,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: _kHeader,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: _kHeader,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // Score hero number
  static const TextStyle scoreHero = TextStyle(
    fontFamily: _kHeader,
    fontSize: 80,
    fontWeight: FontWeight.w900,
    letterSpacing: -4,
    height: 1,
  );
}
