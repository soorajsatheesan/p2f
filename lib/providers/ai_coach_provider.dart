import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2f/models/chat_message.dart';
import 'package:p2f/models/user_profile.dart';
import 'package:p2f/providers/login_provider.dart';
import 'package:p2f/services/ai_coach_service.dart';
import 'package:p2f/services/secure_storage_service.dart';

final aiCoachServiceProvider = Provider<AiCoachService>((ref) {
  return AiCoachService();
});

final aiCoachProvider = StateNotifierProvider<AiCoachNotifier, AiCoachState>((
  ref,
) {
  return AiCoachNotifier(
    coachService: ref.read(aiCoachServiceProvider),
    secureStorage: ref.read(secureStorageProvider),
  );
});

class AiCoachState {
  const AiCoachState({
    this.messages = const [],
    this.isSending = false,
    this.errorMessage,
  });

  final List<ChatMessage> messages;
  final bool isSending;
  final String? errorMessage;

  AiCoachState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    Object? errorMessage = _sentinel,
  }) {
    return AiCoachState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _sentinel = Object();

class AiCoachNotifier extends StateNotifier<AiCoachState> {
  AiCoachNotifier({
    required AiCoachService coachService,
    required SecureStorageService secureStorage,
  }) : _coachService = coachService,
       _secureStorage = secureStorage,
       super(
         AiCoachState(
           messages: [
             ChatMessage(
               role: ChatRole.assistant,
               text:
                   'I am Joe, your AI fitness coach. Ask me training, nutrition, recovery, and habit questions.',
               createdAt: DateTime.now(),
             ),
           ],
         ),
       );

  final AiCoachService _coachService;
  final SecureStorageService _secureStorage;

  Future<void> sendMessage({
    required String userText,
    required UserProfile? profile,
  }) async {
    final trimmed = userText.trim();
    if (trimmed.isEmpty || state.isSending) return;

    final updated = [
      ...state.messages,
      ChatMessage(
        role: ChatRole.user,
        text: trimmed,
        createdAt: DateTime.now(),
      ),
    ];

    state = state.copyWith(
      messages: updated,
      isSending: true,
      errorMessage: null,
    );

    try {
      final key = await _secureStorage.getApiKey(StorageKeys.apiToken);
      if (key == null || key.trim().isEmpty) {
        throw Exception('Gemini API key missing. Reconnect your key.');
      }

      final prompt = _buildPrompt(
        latestUserMessage: trimmed,
        profile: profile,
        history: updated,
      );

      final reply = await _coachService.getReply(apiKey: key, prompt: prompt);
      state = state.copyWith(
        isSending: false,
        messages: [
          ...updated,
          ChatMessage(
            role: ChatRole.assistant,
            text: reply,
            createdAt: DateTime.now(),
          ),
        ],
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  String _buildPrompt({
    required String latestUserMessage,
    required UserProfile? profile,
    required List<ChatMessage> history,
  }) {
    final profileBlock = profile == null
        ? 'Profile unavailable.'
        : 'Profile: name=${profile.name}, age=${profile.age}, weight_kg=${profile.weightKg}, height_cm=${profile.heightCm}, goal=${profile.healthGoal}';

    final convo = history
        .take(history.length > 10 ? 10 : history.length)
        .map((m) => '${m.role == ChatRole.user ? 'User' : 'Joe'}: ${m.text}')
        .join('\n');

    return '''
You are Joe, a health and fitness assistant.
Scope: only fitness, exercise, nutrition, recovery, sleep, healthy habits, and body-composition guidance.
If asked about non-health topics, politely refuse in one short sentence and redirect to health/fitness.
Never claim to diagnose disease. For medical symptoms, advise consulting a qualified professional.
Be concise, practical, and supportive.
Use user's profile context when useful.
$profileBlock

Conversation so far:
$convo

Latest user message:
$latestUserMessage
''';
  }
}
