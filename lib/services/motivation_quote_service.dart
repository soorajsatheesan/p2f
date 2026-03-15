import 'package:p2f/services/openai_service.dart';

class MotivationQuoteService {
  final OpenAiService _openAiService;

  MotivationQuoteService({OpenAiService? openAiService})
    : _openAiService = openAiService ?? OpenAiService();

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
    try {
      final text = await _openAiService.createTextResponse(
        apiKey: apiKey,
        messages: [
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        temperature: 0.8,
        maxCompletionTokens: 180,
      );
      return text.replaceAll('"', '').replaceAll(RegExp(r'\s+'), ' ').trim();
    } catch (_) {
      throw Exception('Could not generate motivation right now.');
    }
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
