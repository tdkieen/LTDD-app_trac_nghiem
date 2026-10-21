import 'package:flutter/material.dart';

class AppColors {
  // Primary Blue & White Palette (Xanh - Trắng)
  static const Color primary = Color(0xFF0D6EFD);       // Vibrant Royal Blue
  static const Color primaryDark = Color(0xFF0A58CA);   // Deep Blue
  static const Color primaryLight = Color(0xFF3D8BFD);  // Lighter Blue
  static const Color primarySoft = Color(0xFFE7F1FF);   // Very soft blue tint

  static const Color secondary = Color(0xFF0284C7);     // Ocean Cyan/Blue
  static const Color secondarySoft = Color(0xFFE0F2FE);

  // Backgrounds & Surface
  static const Color background = Color(0xFFF4F7FB);    // Light grayish-blue canvas
  static const Color surface = Color(0xFFFFFFFF);       // Clean pure white
  static const Color surfaceMuted = Color(0xFFF8FAFC);  // Muted card background

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFEEF2F6);

  // Text colors
  static const Color textPrimary = Color(0xFF0F172A);   // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8);     // Slate 400
  static const Color textOnPrimary = Colors.white;

  // Semantic Status colors
  static const Color success = Color(0xFF10B981);       // Emerald Green
  static const Color successSoft = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);       // Amber Orange
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);        // Crimson Red
  static const Color dangerSoft = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0284C7);
  static const Color infoSoft = Color(0xFFE0F2FE);

  // Difficulty Badges
  static Color difficultyColor(String? diff) {
    switch (diff?.toLowerCase().trim()) {
      case 'dễ':
      case 'de':
        return const Color(0xFF10B981); // Green
      case 'trung bình':
      case 'tb':
        return const Color(0xFFF59E0B); // Orange
      case 'khó':
      case 'kho':
        return const Color(0xFFEF4444); // Red
      default:
        return primary;
    }
  }

  static Color difficultyBg(String? diff) {
    switch (diff?.toLowerCase().trim()) {
      case 'dễ':
      case 'de':
        return const Color(0xFFECFDF5);
      case 'trung bình':
      case 'tb':
        return const Color(0xFFFFFBEB);
      case 'khó':
      case 'kho':
        return const Color(0xFFFEF2F2);
      default:
        return primarySoft;
    }
  }
}
