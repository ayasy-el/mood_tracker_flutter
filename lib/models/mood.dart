import 'package:equatable/equatable.dart';

enum MoodType {
  happy,
  sad,
  angry,
  excited,
  neutral,
  calm,
  anxious,
}

class MoodEntry extends Equatable {
  final MoodType mood;
  final int intensity;
  final DateTime timestamp;
  final String? note;
  final String? imageUrl;
  final String source; // 'camera' or 'manual'

  const MoodEntry({
    required this.mood,
    required this.intensity,
    required this.timestamp,
    this.note,
    this.imageUrl,
    required this.source,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      mood: MoodType.values.firstWhere(
        (e) => e.toString() == 'MoodType.${json['mood']}',
      ),
      intensity: json['intensity'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
      imageUrl: json['imageUrl'] as String?,
      source: json['source'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mood': mood.toString().split('.').last,
      'intensity': intensity,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
      'imageUrl': imageUrl,
      'source': source,
    };
  }

  @override
  List<Object?> get props => [
        mood,
        intensity,
        timestamp,
        note,
        imageUrl,
        source,
      ];

  MoodEntry copyWith({
    MoodType? mood,
    int? intensity,
    DateTime? timestamp,
    String? note,
    String? imageUrl,
    String? source,
  }) {
    return MoodEntry(
      mood: mood ?? this.mood,
      intensity: intensity ?? this.intensity,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
    );
  }
}
