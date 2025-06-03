import 'package:mood_tracker_flutter/models/mood.dart';
import 'package:mood_tracker_flutter/models/journal_entry.dart';
import 'package:mood_tracker_flutter/models/user_profile.dart';

final mockUserProfile = UserProfile(
  id: '1',
  name: 'John Doe',
  avatar: 'https://i.pravatar.cc/300',
  joinDate: DateTime(2023, 1, 1),
  streakDays: 7,
  preferences: const UserPreferences(
    darkMode: false,
    privateJournal: true,
    reminderTime: '20:00',
  ),
);

List<MoodEntry> generateMockMoodHistory() {
  final now = DateTime.now();
  final weekMoodData = [
    (
      MoodType.calm,
      4,
      'Spent time with family and enjoyed relaxation time'
    ), // Wed
    (MoodType.sad, 3, null), // Thu
    (MoodType.anxious, 2, 'Feeling stressed about work deadlines'), // Fri
    (MoodType.calm, 3, null), // Sat
    (MoodType.happy, 4, null), // Sun
    (MoodType.excited, 5, null), // Mon
    (MoodType.calm, 4, 'This is a note for calm mood'), // Tue
  ];

  return List.generate(7, (index) {
    final (mood, intensity, note) = weekMoodData[index];
    return MoodEntry(
      mood: mood,
      intensity: intensity * 2, // Scale to 1-10
      timestamp: now.subtract(Duration(days: 6 - index)),
      source: index % 2 == 0 ? 'camera' : 'manual',
      note: note,
    );
  }).reversed.toList();
}

Map<String, dynamic> getMockMoodStats() {
  return {
    'totalEntries': 31,
    'streakDays': 7,
    'averageIntensity': 5.6,
    'mostFrequentMood': 'calm',
  };
}

List<JournalEntry> generateMockJournalEntries() {
  final now = DateTime.now();
  return [
    JournalEntry(
      id: '1',
      content:
          'Had a great day at work today! Everything went smoothly and I felt very productive.',
      timestamp: now.subtract(const Duration(hours: 3)),
      associatedMood: MoodEntry(
        mood: MoodType.happy,
        intensity: 8,
        timestamp: now.subtract(const Duration(hours: 3)),
        source: 'manual',
      ),
    ),
    JournalEntry(
      id: '2',
      content:
          'Feeling a bit down today. The weather is gloomy and I miss my family.',
      timestamp: now.subtract(const Duration(days: 1)),
      associatedMood: MoodEntry(
        mood: MoodType.sad,
        intensity: 4,
        timestamp: now.subtract(const Duration(days: 1)),
        source: 'manual',
      ),
    ),
    JournalEntry(
      id: '3',
      content:
          'Just got some amazing news! Can\'t wait to share it with everyone!',
      timestamp: now.subtract(const Duration(days: 2)),
      associatedMood: MoodEntry(
        mood: MoodType.excited,
        intensity: 9,
        timestamp: now.subtract(const Duration(days: 2)),
        source: 'manual',
      ),
    ),
  ];
}
