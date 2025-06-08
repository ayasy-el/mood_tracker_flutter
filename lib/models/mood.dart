import 'package:equatable/equatable.dart';
import 'package:mood_tracker_flutter/constants/moods.dart';

class MoodEntry extends Equatable {
  final String content;
  final DateTime timestamp;
  final String mood;
  final List<String> feelings;
  final int intensity;
  final List<String> tags;

  const MoodEntry({
    required this.content,
    required this.timestamp,
    required this.mood,
    required this.feelings,
    required this.intensity,
    required this.tags,
  });

  void validate() {
    assert(MoodConstants.isValidMood(mood), 'Invalid mood: $mood');
    assert(feelings.length <= 3, 'Too many feelings: ${feelings.length}');
    assert(intensity >= 1 && intensity <= 10, 'Invalid intensity: $intensity');
    assert(tags.length <= 3, 'Too many tags: ${tags.length}');
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    final entry = MoodEntry(
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      mood: json['mood'] as String,
      feelings: List<String>.from(json['feelings'] ?? []),
      intensity: json['intensity'] as int,
      tags: List<String>.from(json['tags'] ?? []),
    );
    entry.validate();
    return entry;
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'mood': mood,
      'feelings': feelings,
      'intensity': intensity,
      'tags': tags,
    };
  }

  @override
  List<Object?> get props => [
        content,
        timestamp,
        mood,
        feelings,
        intensity,
        tags,
      ];

  MoodEntry copyWith({
    String? content,
    DateTime? timestamp,
    String? mood,
    List<String>? feelings,
    int? intensity,
    List<String>? tags,
  }) {
    final entry = MoodEntry(
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      mood: mood ?? this.mood,
      feelings: feelings ?? this.feelings,
      intensity: intensity ?? this.intensity,
      tags: tags ?? this.tags,
    );
    entry.validate();
    return entry;
  }
}
