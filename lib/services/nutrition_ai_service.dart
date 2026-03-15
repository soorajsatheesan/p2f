import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:p2f/models/nutrition_analysis.dart';

class NutritionAiService {
  static const String _baseUrl = 'https://api.openai.com/v1/responses';
  static const List<String> _models = ['gpt-4.1-mini', 'gpt-4.1'];

  Future<NutritionAnalysis> analyzeMeal({
    required String apiKey,
    required Uint8List imageBytes,
    required String mimeType,
    required String description,
  }) async {
    Exception? lastError;

    for (final model in _models) {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: _headers(apiKey),
            body: jsonEncode(_buildRequestBody(
              model: model,
              mimeType: mimeType,
              imageBytes: imageBytes,
              description: description,
            )),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode != 200) {
        lastError = Exception(_extractErrorMessage(response.body));
        if (!_shouldTryFallback(response.statusCode)) {
          throw lastError;
        }
        continue;
      }

      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final text = _extractOutputText(data);
        if (text.isEmpty) {
          throw Exception('OpenAI returned an empty nutrition analysis.');
        }

        final parsed = jsonDecode(_extractJsonObject(text)) as Map<String, dynamic>;
        return NutritionAnalysis.fromJson(parsed);
      } catch (e) {
        lastError = Exception(
          e is FormatException
              ? 'OpenAI returned invalid nutrition data.'
              : e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }

    throw lastError ??
        Exception('Unable to analyze this meal right now. Please try again.');
  }

  Map<String, Object?> _buildRequestBody({
    required String model,
    required String mimeType,
    required Uint8List imageBytes,
    required String description,
  }) {
    return {
      'model': model,
      'input': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'input_text',
              'text': _buildPrompt(description),
            },
            {
              'type': 'input_image',
              'image_url': 'data:$mimeType;base64,${base64Encode(imageBytes)}',
              'detail': 'low',
            },
          ],
        },
      ],
      'text': {
        'format': {
          'type': 'json_schema',
          'name': 'nutrition_analysis',
          'strict': true,
          'schema': {
            'type': 'object',
            'additionalProperties': false,
            'required': [
              'meal_name',
              'calories',
              'protein_g',
              'carbs_g',
              'fats_g',
              'fiber_g',
              'summary',
            ],
            'properties': {
              'meal_name': {'type': 'string'},
              'calories': {'type': 'integer'},
              'protein_g': {'type': 'number'},
              'carbs_g': {'type': 'number'},
              'fats_g': {'type': 'number'},
              'fiber_g': {'type': 'number'},
              'summary': {'type': 'string'},
            },
          },
        },
      },
      'max_output_tokens': 350,
    };
  }

  String _buildPrompt(String description) {
    return '''
Estimate the nutrition for the meal shown in the image.

Use both the image and the user description. If the image is unclear, rely more on the description and make the best realistic estimate you can.

User description: "$description"

The summary must be concise and include:
1. A short description of the meal.
2. An estimated ingredient breakdown with gram amounts for the main components.

Example summary style:
Grilled chicken rice bowl with broccoli. Estimated breakdown: chicken 150 g, cooked rice 180 g, broccoli 80 g, sauce 20 g.

Return a complete nutrition estimate for one meal. Do not refuse. Do not ask follow-up questions.
''';
  }

  String _extractOutputText(Map<String, dynamic> data) {
    final direct = data['output_text'] as String?;
    if (direct != null && direct.trim().isNotEmpty) {
      return direct.trim();
    }

    final output = data['output'] as List<dynamic>?;
    if (output == null) return '';

    final buffer = StringBuffer();

    for (final item in output.whereType<Map>()) {
      final itemMap = Map<String, dynamic>.from(item);
      final content = itemMap['content'] as List<dynamic>?;
      if (content == null) continue;

      for (final part in content.whereType<Map>()) {
        final partMap = Map<String, dynamic>.from(part);
        final text = partMap['text'] as String?;
        if (text != null && text.trim().isNotEmpty) {
          if (buffer.isNotEmpty) buffer.write(' ');
          buffer.write(text.trim());
        }
      }
    }

    return buffer.toString().trim();
  }

  String _extractJsonObject(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      return trimmed;
    }

    final start = trimmed.indexOf('{');
    final end = trimmed.lastIndexOf('}');
    if (start >= 0 && end > start) {
      return trimmed.substring(start, end + 1);
    }

    return trimmed;
  }

  String _extractErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final error = decoded['error'] as Map<String, dynamic>?;
      final message = error?['message'] as String?;
      if (message != null && message.trim().isNotEmpty) {
        return message.trim();
      }
    } catch (_) {
      // Fall through.
    }

    return 'Unable to analyze this meal right now. Please try again.';
  }

  bool _shouldTryFallback(int statusCode) {
    return statusCode == 400 || statusCode == 404;
  }

  Map<String, String> _headers(String apiKey) {
    return {
      'Authorization': 'Bearer ${apiKey.trim()}',
      'Content-Type': 'application/json',
    };
  }
}
