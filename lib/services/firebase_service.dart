import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mood_tracker_flutter/models/mood.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String _moodEntriesCollection = 'mood_entries';

  // Mood Entry methods
  Future<void> createMoodEntry(MoodEntry entry) async {
    final docRef = _firestore.collection(_moodEntriesCollection).doc();

    final entryWithId = entry.copyWith(id: docRef.id);
    await docRef.set(entryWithId.toJson());
  }

  Future<void> updateMoodEntry(String entryId, MoodEntry entry) async {
    final entryWithId = entry.copyWith(id: entryId);
    await _firestore
        .collection(_moodEntriesCollection)
        .doc(entryId)
        .update(entryWithId.toJson());
  }

  Future<void> deleteMoodEntry(String entryId) async {
    await _firestore.collection(_moodEntriesCollection).doc(entryId).delete();
  }

  Stream<List<MoodEntry>> getMoodEntriesStream() {
    return _firestore
        .collection(_moodEntriesCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MoodEntry.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<List<MoodEntry>> getMoodEntries() async {
    final snapshot = await _firestore
        .collection(_moodEntriesCollection)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => MoodEntry.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  // Stats methods
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final entries = await getMoodEntries();
      if (entries.isEmpty) {
        return {
          'totalEntries': 0,
          'avgIntensity': 0.0,
          'mostFrequentMood': '',
          'streakDays': 0,
        };
      }

      final moodFrequency = <String, int>{};
      var totalIntensity = 0;

      for (final entry in entries) {
        moodFrequency[entry.mood] = (moodFrequency[entry.mood] ?? 0) + 1;
        totalIntensity += entry.intensity;
      }

      final mostFrequentMood =
          moodFrequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      return {
        'totalEntries': entries.length,
        'avgIntensity': totalIntensity / entries.length,
        'mostFrequentMood': mostFrequentMood,
        'streakDays': _calculateStreak(entries),
      };
    } catch (e) {
      return {
        'totalEntries': 0,
        'avgIntensity': 0.0,
        'mostFrequentMood': '',
        'streakDays': 0,
      };
    }
  }

  int _calculateStreak(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0;

    var streak = 1;
    var currentDate = DateTime.now();
    final dates = entries
        .map((e) => DateTime(
              e.timestamp.year,
              e.timestamp.month,
              e.timestamp.day,
            ))
        .toSet();

    while (currentDate.difference(entries.last.timestamp).inDays <= 30) {
      final yesterday = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      ).subtract(const Duration(days: 1));

      if (!dates.contains(yesterday)) break;
      streak++;
      currentDate = yesterday;
    }

    return streak;
  }
}
