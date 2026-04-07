import 'package:flutter/material.dart';

class AppColors {
  // Editorial Palette
  static const Color editorialBackground = Color(0xFFFFFFFF);
  static const Color editorialTextPrimary = Color(0xFF000000);
  static const Color editorialTextSecondary = Color(0xFF444444);
  static const Color editorialCardBackground = Color(0xFFF5F5F5);
  static const Color editorialDivider = Color(0xFFEAEAEA);

  // Anxiety Level Indicators (Semantic)
  static const Color anxietyLow = Color(0xFF10B981);      // Emerald/Green
  static const Color anxietyModerate = Color(0xFFF59E0B); // Amber/Orange
  static const Color anxietyHigh = Color(0xFFEF4444);     // Red

  // Emotion Colors (Editorial Styled)
  static const Color emotionHappy = Color(0xFF10B981);
  static const Color emotionNeutral = Color(0xFF94A3B8);
  static const Color emotionSad = Color(0xFF6366F1);
  static const Color emotionAngry = Color(0xFFEF4444);
  static const Color emotionFear = Color(0xFF8B5CF6);
  static const Color emotionSurprise = Color(0xFFF59E0B);
  static const Color emotionDisgust = Color(0xFF14B8A6);

  // Helper for maps or dynamic access
  static Color getAnxietyColor(String level) {
    switch (level.toLowerCase()) {
      case 'low': return anxietyLow;
      case 'moderate': return anxietyModerate;
      case 'high': return anxietyHigh;
      default: return editorialTextSecondary;
    }
  }
}
