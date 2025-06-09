import 'package:flutter/foundation.dart';
import 'package:mood_tracker_flutter/models/mood.dart';
import 'package:mood_tracker_flutter/services/firebase_service.dart';

class FirebaseProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<MoodEntry> _moodEntries = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<MoodEntry> get moodEntries => _moodEntries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize the provider
  Future<void> initialize() async {
    try {
      _setLoading(true);

      // Start listening to mood entries
      _firebaseService.getMoodEntriesStream().listen(
        (entries) {
          _moodEntries = entries;
          notifyListeners();
        },
        onError: (error) {
          _setError(error.toString());
        },
      );
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Mood Entry methods
  Future<void> createMoodEntry(MoodEntry entry) async {
    try {
      _setLoading(true);
      await _firebaseService.createMoodEntry(entry);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateMoodEntry(String entryId, MoodEntry entry) async {
    try {
      _setLoading(true);
      await _firebaseService.updateMoodEntry(entryId, entry);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteMoodEntry(String entryId) async {
    try {
      _setLoading(true);
      await _firebaseService.deleteMoodEntry(entryId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Stats methods
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      return await _firebaseService.getUserStats();
    } catch (e) {
      _setError(e.toString());
      return {
        'totalEntries': 0,
        'avgIntensity': 0.0,
        'mostFrequentMood': '',
        'streakDays': 0,
      };
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
