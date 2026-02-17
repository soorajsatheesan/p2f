import 'dart:convert';

import 'package:http/http.dart' as http;

class MotivationQuoteService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _model = 'gemini-3-flash-preview';

  Future<String> generateQuote({
    required String apiKey,
    required String prompt,
  }) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      final text = await _requestQuote(apiKey: apiKey, prompt: prompt);
      if (!_looksIncomplete(text)) {
        return text;
      }
    }

    throw Exception('Could not generate a complete motivation quote.');
  }

  Future<String> _requestQuote({
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
      'generationConfig': {'temperature': 0.8, 'maxOutputTokens': 180},
    };

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Could not generate motivation right now.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('No motivation generated.');
    }

    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    final text = parts
        ?.map((part) => (part as Map<String, dynamic>)['text'] as String?)
        .whereType<String>()
        .join(' ')
        .trim();

    if (text == null || text.trim().isEmpty) {
      throw Exception('Empty motivation response.');
    }

    return text.replaceAll('"', '').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  bool _looksIncomplete(String text) {
    final words = text
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .length;
    if (words < 6) return true;
    if (text.endsWith("'")) return true;
    if (text.endsWith(',')) return true;
    return false;
  }
}
