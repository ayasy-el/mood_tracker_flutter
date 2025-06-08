import 'package:flutter/material.dart';

class MoodConstants {
  static const List<String> availableMoods = [
    'Happy',
    'Sad',
    'Angry',
    'Neutral',
    'Calm',
    'Excited',
    'Anxious',
    'Tired',
  ];

  static const Map<String, List<String>> moodFeelings = {
    'Happy': [
      'Grateful',
      'Loved',
      'Connected',
      'Confident',
      'Inspired',
      'Content',
      'Energetic',
      'Hopeful',
      'Peaceful',
      'Motivated',
    ],
    'Sad': [
      'Lonely',
      'Disappointed',
      'Hopeless',
      'Empty',
      'Hurt',
      'Lost',
      'Nostalgic',
      'Regretful',
      'Heartbroken',
      'Insecure',
    ],
    'Angry': [
      'Frustrated',
      'Annoyed',
      'Betrayed',
      'Irritated',
      'Furious',
      'Resentful',
      'Jealous',
      'Impatient',
      'Offended',
      'Aggressive',
    ],
    'Neutral': [
      'Indifferent',
      'Reserved',
      'Detached',
      'Balanced',
      'Stable',
      'Composed',
      'Steady',
      'Moderate',
      'Even',
      'Regular',
    ],
    'Calm': [
      'Peaceful',
      'Relaxed',
      'Serene',
      'Tranquil',
      'Centered',
      'Mindful',
      'Grounded',
      'Composed',
      'Balanced',
      'Harmonious',
    ],
    'Excited': [
      'Enthusiastic',
      'Energetic',
      'Thrilled',
      'Eager',
      'Passionate',
      'Inspired',
      'Motivated',
      'Adventurous',
      'Optimistic',
      'Joyful',
    ],
    'Anxious': [
      'Stressed',
      'Worried',
      'Overwhelmed',
      'Nervous',
      'Restless',
      'Uneasy',
      'Tense',
      'Panicked',
      'Insecure',
      'Fearful',
    ],
    'Tired': [
      'Exhausted',
      'Drained',
      'Sleepy',
      'Fatigued',
      'Lethargic',
      'Burned out',
      'Weary',
      'Heavy',
      'Sluggish',
      'Drowsy',
    ],
  };

  static const List<String> availableFeelings = [
    'Bored',
    'Stressed',
    'Grateful',
    'Lonely',
    'Confused',
    'Motivated',
    'Overwhelmed',
    'Connected',
    'Loved',
    'Focused',
    'Frustrated',
    'Peaceful',
    'Energetic',
    'Hopeful',
    'Insecure',
    'Confident',
    'Inspired',
    'Nostalgic',
    'Content',
    'Restless',
  ];

  static const List<String> availableTags = [
    'work',
    'stress',
    'relax',
    'family',
    'love',
    'health',
    'study',
    'friendship',
    'travel',
    'achievement',
    'disappointment',
    'anxiety',
    'excitement',
    'fatigue',
    'motivation',
    'creativity',
    'social',
    'personal',
    'professional',
    'emotional',
  ];

  static bool isValidMood(String mood) {
    return availableMoods.contains(mood);
  }

  static List<String> getMoodFeelings(String mood) {
    return moodFeelings[mood] ?? [];
  }

  static bool isValidFeeling(String feeling) {
    return availableFeelings.contains(feeling);
  }

  static bool isValidTag(String tag) {
    return availableTags.contains(tag);
  }

  static IconData getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_very_dissatisfied;
      case 'angry':
        return Icons.mood_bad;
      case 'neutral':
        return Icons.sentiment_neutral;
      case 'excited':
        return Icons.celebration;
      case 'calm':
        return Icons.spa;
      case 'anxious':
        return Icons.warning_amber;
      default:
        return Icons.sentiment_neutral;
    }
  }
}
