import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OllamaService {
  static const String _baseUrl = 'http://localhost:11434/api';

  static String _extractJsonFromMarkdown(String markdown) {
    final RegExp jsonRegex = RegExp(r'```json\s*(.*?)\s*```', dotAll: true);
    final match = jsonRegex.firstMatch(markdown);
    if (match != null && match.groupCount >= 1) {
      return match.group(1) ?? '{}';
    }
    return markdown; // Return as is if no markdown wrapper found
  }

  static Future<Map<String, dynamic>> analyzeMoodFromText(String text) async {
    final prompt = '''
{
"mood": "pilih salah satu dari: Happy, Sad, Angry, Neutral, Calm, Excited, Anxious, Tired",
"feelings": ["maksimal 3 feeling deskriptif, opsional"],
"intensity": nilai_kepercayaan_1_hingga_10,
"tags": ["maksimal 3 tag dari daftar"],
"explanation": "penjelasan ringkas tentang bagaimana mood dan feelings dideteksi dari teks"
}

Teks yang dianalisis: "$text"

Contoh Feeling:
'Grateful', 'Loved', 'Lonely','Disappointed', 'Hopeless', 'Frustrated', 'Annoyed', 'Indifferent', 'Peaceful', 'Relaxed', 'Enthusiastic', 'Energetic', 'Stressed',
'Worried', Overwhelmed', 'Nervous','Sleepy', 'Fatigued', Burned out'

Tags yang tersedia:
["work", "stress", "relax", "family", "love", "health", "study", "friendship", "travel", "achievement", "disappointment", "anxiety", "excitement", "fatigue", "motivation", "creativity", "social", "personal", "professional", "emotional"]

Mood tidak boleh Mixed, hanya boleh salah satu dari yang tersedia (Happy, Sad, Angry, Neutral, Calm, Excited, Anxious, Tired).
Berikan hanya respons JSON tanpa penjelasan tambahan.
''';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'gemma3:4b',
          'prompt': prompt,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final cleanJson = _extractJsonFromMarkdown(jsonResponse['response']);
        final jsonResult = jsonDecode(cleanJson);
        return jsonResult;
      }
      throw Exception('Failed to analyze mood: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error analyzing mood: $e');
    }
  }

//   static Future<Map<String, dynamic>> analyzeMoodFromImage(
//       Uint8List imageBytes) async {
//     try {
//       // Validate image bytes
//       if (imageBytes.isEmpty) {
//         throw Exception('Image data is empty');
//       }

//       // Log image size
//       debugPrint('Image size: ${imageBytes.length / 1024} KB');

//       // Convert to base64
//       final base64Image = base64Encode(imageBytes);
//       debugPrint('Base64 image length: ${base64Image.length}');

//       const prompt = '''
// {
// "mood": "pilih salah satu dari: Happy, Sad, Angry, Neutral, Calm, Excited, Anxious, Tired",
// "feelings": ["maksimal 3 feeling deskriptif, opsional"],
// "intensity": 1-10,
// "tags": ["maksimal 3 tag dari daftar"],
// "explanation": "penjelasan ringkas tentang bagaimana mood dan feelings dideteksi dari teks"
// }

// Contoh Feeling:
// 'Grateful', 'Loved', 'Lonely','Disappointed', 'Hopeless', 'Frustrated', 'Annoyed', 'Indifferent', 'Peaceful', 'Relaxed', 'Enthusiastic', 'Energetic', 'Stressed',
// 'Worried', Overwhelmed', 'Nervous','Sleepy', 'Fatigued', Burned out'

// Tags yang tersedia:
// ["work", "stress", "relax", "family", "love", "health", "study", "friendship", "travel", "achievement", "disappointment", "anxiety", "excitement", "fatigue", "motivation", "creativity", "social", "personal", "professional", "emotional"]

// Mood tidak boleh Mixed, hanya boleh salah satu dari yang tersedia (Happy, Sad, Angry, Neutral, Calm, Excited, Anxious, Tired).
// Berikan hanya respons JSON tanpa penjelasan tambahan.
// ''';

//       final requestBody = {
//         'model': 'gemma3:4b',
//         'prompt': prompt,
//         'images': [base64Image],
//         'stream': false,
//       };

//       debugPrint('Sending request to Ollama...');
//       final response = await http.post(
//         Uri.parse('$_baseUrl/generate'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );

//       debugPrint('Response status code: ${response.statusCode}');
//       debugPrint('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         final cleanJson = _extractJsonFromMarkdown(jsonResponse['response']);
//         final jsonResult = jsonDecode(cleanJson);
//         return jsonResult;
//       }

//       throw Exception(
//           'Failed to analyze image: ${response.statusCode} - ${response.body}');
//     } catch (e, stackTrace) {
//       debugPrint('Error analyzing image: $e');
//       debugPrint('Stack trace: $stackTrace');
//       throw Exception('Error analyzing image: $e');
//     }
//   }
}
