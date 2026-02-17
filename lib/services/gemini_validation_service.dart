import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiValidationService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _model = 'gemini-3-flash-preview';

  /// Validates the API key by making a test request to Gemini
  /// Returns true if the key is valid and working
  Future<bool> validateApiKey(String apiKey) async {
    final sanitizedKey = apiKey.trim();
    if (sanitizedKey.isEmpty) {
      return false;
    }

    try {
      // First, do a lightweight auth check. If this succeeds, the key is valid.
      final modelsUrl = Uri.parse('$_baseUrl?key=$sanitizedKey');
      final modelsResponse = await http
          .get(modelsUrl)
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

      final url = Uri.parse(
        '$_baseUrl/$_model:generateContent?key=$sanitizedKey',
      );

      final requestBody = <String, Object>{
        'contents': [
          {
            'parts': [
              {'text': 'Return one short word.'},
            ],
          },
        ],
        'generationConfig': {'temperature': 0, 'maxOutputTokens': 10},
      };

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      if (response.statusCode == 200) {
        // 200 means key + endpoint access are valid.
        return true;
      } else if (response.statusCode == 400) {
        // Bad request - likely invalid model or malformed request
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? '';

        if (errorMessage.contains('models') ||
            errorMessage.contains('not found')) {
          return _tryAlternativeModel(apiKey);
        }
        return false;
      } else if (_isAuthError(response.statusCode)) {
        // Unauthorized - invalid API key
        return false;
      } else {
        // Other errors
        return false;
      }
    } catch (e) {
      // Network or parsing error
      rethrow;
    }
  }

  Future<bool> _tryAlternativeModel(String apiKey) async {
    const fallbackModels = <String>['gemini-2.0-flash-exp', 'gemini-1.5-flash'];

    for (final model in fallbackModels) {
      final isValid = await _validateWithModel(apiKey, model);
      if (isValid) {
        return true;
      }
    }

    return false;
  }

  Future<bool> _validateWithModel(String apiKey, String model) async {
    try {
      final url = Uri.parse('$_baseUrl/$model:generateContent?key=$apiKey');

      final requestBody = <String, Object>{
        'contents': [
          {
            'parts': [
              {'text': 'Return one short word.'},
            ],
          },
        ],
        'generationConfig': {'temperature': 0, 'maxOutputTokens': 10},
      };

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      if (response.statusCode != 200) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  bool _isAuthError(int statusCode) {
    return statusCode == 401 || statusCode == 403;
  }
}
