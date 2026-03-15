import 'package:p2f/services/openai_service.dart';
import 'package:p2f/services/chat_text_formatter.dart';

class AiCoachService {
  final OpenAiService _openAiService;

  AiCoachService({OpenAiService? openAiService})
    : _openAiService = openAiService ?? OpenAiService();

  Future<String> getReply({
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
        temperature: 0.5,
        maxCompletionTokens: 350,
      );
      return ChatTextFormatter.sanitizeAssistantText(text);
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '').trim();
      if (message.isEmpty) {
        throw Exception('The AI companion is unavailable right now. Try again.');
      }
      throw Exception(message);
    }
  }
}
