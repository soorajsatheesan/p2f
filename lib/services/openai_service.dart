import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenAiService {
  static const String baseUrl = 'https://api.openai.com/v1';
  static const List<String> textModels = ['gpt-5-mini', 'gpt-4.1-mini'];

  Future<String> createTextResponse({
    required String apiKey,
    required List<Map<String, Object?>> messages,
    double temperature = 0.7,
    int maxCompletionTokens = 300,
    Map<String, Object?>? responseFormat,
  }) async {
    Exception? lastError;

    for (final model in textModels) {
      final response = await http
          .post(
            Uri.parse('$baseUrl/chat/completions'),
            headers: _headers(apiKey),
            body: jsonEncode({
              'model': model,
              'messages': messages,
              'temperature': temperature,
              'max_completion_tokens': maxCompletionTokens,
              ...?responseFormat == null
                  ? null
                  : {'response_format': responseFormat},
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        lastError = Exception(_extractErrorMessage(response.body));
        if (!_shouldTryFallback(response.statusCode)) {
          throw lastError;
        }
        continue;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw Exception('No response was returned. Please try again.');
      }

      final message = choices.first['message'] as Map<String, dynamic>?;
      final text = _extractMessageText(message?['content']);
      if (text.isNotEmpty) {
        return text;
      }

      throw Exception('The model returned an empty response. Please try again.');
    }

    throw lastError ?? Exception('OpenAI request failed.');
  }

  Future<String> analyzeImageAsJson({
    required String apiKey,
    required String prompt,
    required String mimeType,
    required String imageBase64,
    required Map<String, Object?> jsonSchema,
  }) async {
    Exception? lastError;

    for (final model in textModels) {
      final response = await _postChatCompletion(
        apiKey: apiKey,
        body: {
          'model': model,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': prompt,
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:$mimeType;base64,$imageBase64',
                    'detail': 'low',
                  },
                },
              ],
            },
          ],
          'max_completion_tokens': 400,
          'response_format': {
            'type': 'json_schema',
            'json_schema': {
              'name': 'nutrition_analysis',
              'strict': true,
              'schema': jsonSchema,
            },
          },
        },
      );

      if (response.statusCode != 200) {
        lastError = Exception(_extractErrorMessage(response.body));
        if (!_shouldTryFallback(response.statusCode)) {
          throw lastError;
        }
        continue;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw Exception('No analysis was returned. Please try again.');
      }

      final choice = choices.first as Map<String, dynamic>;
      final message = choice['message'] as Map<String, dynamic>?;

      // Structured outputs: model may refuse instead of responding
      final refusal = message?['refusal'] as String?;
      if (refusal != null && refusal.trim().isNotEmpty) {
        throw Exception(
          "The model couldn't analyze this image. Try a clearer or closer photo.",
        );
      }

      final text = _extractMessageText(message?['content']);
      if (text.isEmpty) {
        // Check finish_reason for content filter
        final finishReason = choice['finish_reason'] as String?;
        if (finishReason == 'content_filter') {
          throw Exception(
            'The image could not be processed. Please try a different photo.',
          );
        }

        // Retry once without structured outputs in case the model returned
        // plain text JSON instead of a schema-bound response.
        final fallbackText = await _analyzeImageAsPlainJson(
          apiKey: apiKey,
          model: model,
          prompt: prompt,
          mimeType: mimeType,
          imageBase64: imageBase64,
        );
        if (fallbackText.isNotEmpty) {
          return fallbackText;
        }

        throw Exception(
          "Couldn't analyze this meal. Please try again with a clearer photo.",
        );
      }

      return text;
    }

    throw lastError ?? Exception('Analysis request failed. Check your connection and try again.');
  }

  Map<String, String> _headers(String apiKey) {
    return {
      'Authorization': 'Bearer ${apiKey.trim()}',
      'Content-Type': 'application/json',
    };
  }

  Future<http.Response> _postChatCompletion({
    required String apiKey,
    required Map<String, Object?> body,
  }) {
    return http
        .post(
          Uri.parse('$baseUrl/chat/completions'),
          headers: _headers(apiKey),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));
  }

  String _extractErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final message = decoded['error']?['message'] as String?;
      if (message != null && message.trim().isNotEmpty) {
        return message.trim();
      }
    } catch (_) {
      // Fall through to default message.
    }

    return 'Analysis request failed. Please try again.';
  }

  bool _shouldTryFallback(int statusCode) {
    return statusCode == 400 || statusCode == 404;
  }

  String _extractMessageText(Object? content) {
    if (content is String && content.trim().isNotEmpty) {
      return content.trim();
    }

    if (content is List) {
      final text = content
          .map((part) => part is Map ? Map<String, dynamic>.from(part) : null)
          .whereType<Map<String, dynamic>>()
          .where((part) => part['type'] == 'text')
          .map((part) => part['text'] as String?)
          .whereType<String>()
          .join(' ')
          .trim();
      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }

  Future<String> _analyzeImageAsPlainJson({
    required String apiKey,
    required String model,
    required String prompt,
    required String mimeType,
    required String imageBase64,
  }) async {
    final fallbackPrompt = '''
$prompt

Return a single valid JSON object with these keys exactly:
meal_name, calories, protein_g, carbs_g, fats_g, fiber_g, summary
''';

    final response = await _postChatCompletion(
      apiKey: apiKey,
      body: {
        'model': model,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': fallbackPrompt,
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:$mimeType;base64,$imageBase64',
                  'detail': 'low',
                },
              },
            ],
          },
        ],
        'max_completion_tokens': 400,
        'response_format': {'type': 'json_object'},
      },
    );

    if (response.statusCode != 200) {
      return '';
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      return '';
    }

    final message = (choices.first as Map<String, dynamic>)['message']
        as Map<String, dynamic>?;
    return _extractMessageText(message?['content']);
  }
}
