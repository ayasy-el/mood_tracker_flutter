import 'package:flutter/cupertino.dart';

class AppColors {
  static const Color primary = CupertinoColors.activeBlue;
  static const Color background = Color(0xFFF5F5F5);
  static const Color textPrimary = CupertinoColors.black;
  static const Color textSecondary = CupertinoColors.systemGrey;
  static const Color error = CupertinoColors.destructiveRed;
  static const Color success = CupertinoColors.activeGreen;
  static const Color warning = CupertinoColors.systemYellow;
  static const Color info = CupertinoColors.activeBlue;

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
        return CupertinoColors.systemYellow;
      case 'sad':
        return CupertinoColors.systemBlue;
      case 'angry':
        return CupertinoColors.systemRed;
      case 'anxious':
        return CupertinoColors.systemPurple;
      case 'calm':
        return CupertinoColors.systemGreen;
      case 'excited':
        return CupertinoColors.systemOrange;
      case 'tired':
        return CupertinoColors.systemGrey;
      case 'neutral':
        return CupertinoColors.systemGrey;
      default:
        return primary;
    }
  }

  static Color getEmotionColor(String? emotion) {
    if (emotion == null) return primary;

    switch (emotion.toLowerCase()) {
      case 'senang':
        return CupertinoColors.systemYellow;
      case 'sedih':
        return CupertinoColors.systemBlue;
      case 'marah':
        return CupertinoColors.systemRed;
      case 'takut':
        return CupertinoColors.systemPurple;
      case 'jijik':
        return CupertinoColors.systemGreen;
      case 'terkejut':
        return CupertinoColors.systemOrange;
      default:
        return primary;
    }
  }
}
