import 'package:flutter/material.dart';

/// Design tokens according to DESIGN.md (Warm Sunset Modernism)
class AppColors {
  // Primary Accent & Gradients
  static const Color primaryOrange = Color(0xFFFF6B4A);
  static const Color gradientStart = Color(0xFFFF8C66);
  static const Color gradientEnd = Color(0xFFFF4D2D);

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  // Backgrounds & Surfaces
  static const Color darkBackground = Color(0xFF121318);
  static const Color darkCardSurface = Color(0x14FFFFFF); // 8% white glassmorphism
  static const Color lightBackgroundStart = Color(0xFFFFE8DE);
  static const Color lightBackgroundEnd = Color(0xFFF6F5F2);
  static const Color lightCardSurface = Color(0xFFFFFFFF);

  // Typography Colors
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9E9EA7);
  static const Color lightTextPrimary = Color(0xFF1A1B20);
  static const Color lightTextSecondary = Color(0xFF767882);

  // Swatches / Accent Palette
  static const Color obsidianBlack = Color(0xFF18181B);
  static const Color slateGrey = Color(0xFF64748B);
  static const Color sageOliveGreen = Color(0xFF4D5D4E);
  static const Color nudeBeige = Color(0xFFE3DAC9);
  static const Color sunsetCoral = Color(0xFFFF6B4A);
}
