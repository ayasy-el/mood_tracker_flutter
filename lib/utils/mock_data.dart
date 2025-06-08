import 'package:mood_tracker_flutter/models/mood.dart';
import 'package:mood_tracker_flutter/constants/moods.dart';

List<MoodEntry> generateMockEntries() {
  return [
    MoodEntry(
      content:
          "Hari ini saya merasa sangat produktif di kantor. Berhasil menyelesaikan proyek tepat waktu.",
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      mood: "Happy",
      feelings: ["Motivated", "Focused"],
      intensity: 8,
      tags: ["work", "achievement"],
    ),
    MoodEntry(
      content: "Bertengkar dengan teman dekat. Rasanya sedih dan kecewa.",
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      mood: "Sad",
      feelings: ["Lonely", "Confused"],
      intensity: 4,
      tags: ["friendship", "emotional"],
    ),
    MoodEntry(
      content:
          "Menghabiskan waktu bersama keluarga di taman. Momen yang menyenangkan.",
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      mood: "Happy",
      feelings: ["Connected", "Loved"],
      intensity: 9,
      tags: ["family", "relax"],
    ),
    MoodEntry(
      content:
          "Deadline menumpuk, banyak yang harus dikerjakan. Merasa tertekan.",
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      mood: "Anxious",
      feelings: ["Stressed", "Overwhelmed"],
      intensity: 7,
      tags: ["work", "stress"],
    ),
    MoodEntry(
      content:
          "Berhasil menyelesaikan ujian dengan baik. Usaha keras terbayarkan.",
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      mood: "Excited",
      feelings: ["Motivated", "Confident"],
      intensity: 8,
      tags: ["study", "achievement"],
    ),
  ];
}
