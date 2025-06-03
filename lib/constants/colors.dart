import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6200EE);
  static const Color background = Color(0xFFF5F5F5);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1D1D1D);
  static const Color textSecondary = Color(0xFF757575);
  static const Color border = Color(0xFFE0E0E0);
  static const Color error = Color(0xFFB00020);

  // Mood colors
  static const Color happy = Color(0xFF4CAF50);
  static const Color sad = Color(0xFF2196F3);
  static const Color angry = Color(0xFFE53935);
  static const Color neutral = Color(0xFF9E9E9E);
  static const Color excited = Color(0xFFFF9800);
  static const Color calm = Color(0xFF00BCD4);
  static const Color anxious = Color(0xFFFF5722);

  static Color getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return happy;
      case 'sad':
        return sad;
      case 'angry':
        return angry;
      case 'neutral':
        return neutral;
      case 'excited':
        return excited;
      case 'calm':
        return calm;
      case 'anxious':
        return anxious;
      default:
        return primary;
    }
  }
}
