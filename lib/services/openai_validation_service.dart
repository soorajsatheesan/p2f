import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenAiValidationService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const List<String> _models = ['gpt-5-mini', 'gpt-4.1-mini'];

  Future<bool> validateApiKey(String apiKey) async {
    final sanitizedKey = apiKey.trim();
    if (sanitizedKey.isEmpty) {
      return false;
    }

    try {
      for (final model in _models) {
        final modelsUrl = Uri.parse('$_baseUrl/models/$model');
        final modelsResponse = await http
            .get(modelsUrl, headers: _headers(sanitizedKey))
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                throw Exception('Request timeout');
              },
            );

        if (modelsResponse.statusCode == 200) {
          return true;
        }

        if (_isAuthError(modelsResponse.statusCode)) {
          return false;
        }

        final response = await http
            .post(
              Uri.parse('$_baseUrl/chat/completions'),
              headers: _headers(sanitizedKey),
              body: jsonEncode({
                'model': model,
                'messages': [
                  {
                    'role': 'user',
                    'content': 'Return one short word.',
                  },
                ],
                'max_completion_tokens': 10,
                'temperature': 0,
              }),
            )
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                throw Exception('Request timeout');
              },
            );

        if (response.statusCode == 200) {
          return true;
        }

        if (_isAuthError(response.statusCode)) {
          return false;
        }
      }

      return false;
    } catch (e) {
      rethrow;
    }
  }

  Map<String, String> _headers(String apiKey) {
    return {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
  }

  bool _isAuthError(int statusCode) {
    return statusCode == 401 || statusCode == 403;
  }
}
