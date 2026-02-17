import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:p2f/models/nutrition_analysis.dart';

class NutritionAiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _model = 'gemini-3-flash-preview';

  Future<NutritionAnalysis> analyzeMeal({
    required String apiKey,
    required Uint8List imageBytes,
    required String mimeType,
    required String description,
  }) async {
    final prompt =
        '''
You are a nutrition analysis assistant.
Analyze the meal image and user description.
Return STRICT JSON only with this schema:
{
  "calories": int,
  "protein_g": number,
  "carbs_g": number,
  "fats_g": number,
  "fiber_g": number,
  "summary": string
}
No markdown, no extra text.
User description: "$description"
''';

    final url = Uri.parse('$_baseUrl/$_model:generateContent?key=$apiKey');

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Encode(imageBytes),
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.2,
        'responseMimeType': 'application/json',
      },
    };

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Gemini request failed (${response.statusCode}).');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('No analysis returned by Gemini.');
    }

    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    final text = parts?.isNotEmpty == true
        ? parts!.first['text'] as String?
        : null;
    if (text == null || text.trim().isEmpty) {
      throw Exception('Empty analysis from Gemini.');
    }

    final parsed = jsonDecode(text) as Map<String, dynamic>;
    return NutritionAnalysis.fromJson(parsed);
  }
}
