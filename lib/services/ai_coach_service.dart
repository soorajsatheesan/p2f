import 'dart:convert';

import 'package:http/http.dart' as http;

class AiCoachService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _model = 'gemini-3-flash-preview';

  Future<String> getReply({
    required String apiKey,
    required String prompt,
  }) async {
    final url = Uri.parse('$_baseUrl/$_model:generateContent?key=$apiKey');

    final body = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {'temperature': 0.5, 'maxOutputTokens': 350},
    };

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Joe is unavailable right now.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('No response from Joe.');
    }

    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    final text = parts?.isNotEmpty == true
        ? (parts!.first['text'] as String?)
        : null;

    if (text == null || text.trim().isEmpty) {
      throw Exception('Empty response from Joe.');
    }

    return text.trim();
  }
}
