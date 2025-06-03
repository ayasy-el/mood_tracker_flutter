import 'package:equatable/equatable.dart';
import 'package:mood_tracker_flutter/models/mood.dart';

class JournalEntry extends Equatable {
  final String id;
  final String content;
  final DateTime timestamp;
  final MoodEntry? associatedMood;

  const JournalEntry({
    required this.id,
    required this.content,
    required this.timestamp,
    this.associatedMood,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      associatedMood: json['associatedMood'] != null
          ? MoodEntry.fromJson(json['associatedMood'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'associatedMood': associatedMood?.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, content, timestamp, associatedMood];

  JournalEntry copyWith({
    String? id,
    String? content,
    DateTime? timestamp,
    MoodEntry? associatedMood,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      associatedMood: associatedMood ?? this.associatedMood,
    );
  }
}
