import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2f/models/user_profile.dart';
import 'package:p2f/providers/login_provider.dart';
import 'package:p2f/services/motivation_quote_service.dart';
import 'package:p2f/services/secure_storage_service.dart';

final motivationQuoteServiceProvider = Provider<MotivationQuoteService>((ref) {
  return MotivationQuoteService();
});

final motivationQuoteProvider =
    StateNotifierProvider<MotivationQuoteNotifier, MotivationQuoteState>((ref) {
      return MotivationQuoteNotifier(
        quoteService: ref.read(motivationQuoteServiceProvider),
        secureStorage: ref.read(secureStorageProvider),
      );
    });

class MotivationQuoteState {
  const MotivationQuoteState({
    this.quote,
    this.isLoading = false,
    this.errorMessage,
    this.profileSignature,
  });

  final String? quote;
  final bool isLoading;
  final String? errorMessage;
  final String? profileSignature;

  MotivationQuoteState copyWith({
    Object? quote = _sentinel,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    Object? profileSignature = _sentinel,
  }) {
    return MotivationQuoteState(
      quote: identical(quote, _sentinel) ? this.quote : quote as String?,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      profileSignature: identical(profileSignature, _sentinel)
          ? this.profileSignature
          : profileSignature as String?,
    );
  }
}

const Object _sentinel = Object();

class MotivationQuoteNotifier extends StateNotifier<MotivationQuoteState> {
  MotivationQuoteNotifier({
    required MotivationQuoteService quoteService,
    required SecureStorageService secureStorage,
  }) : _quoteService = quoteService,
       _secureStorage = secureStorage,
       super(const MotivationQuoteState());

  final MotivationQuoteService _quoteService;
  final SecureStorageService _secureStorage;

  Future<void> fetchForProfile({
    required UserProfile profile,
    bool force = false,
  }) async {
    if (state.isLoading) return;

    final signature = _signatureFor(profile);
    final alreadyLoaded =
        state.quote != null && state.profileSignature == signature;
    if (!force && alreadyLoaded) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final apiKey = await _secureStorage.getApiKey(StorageKeys.apiToken);
      if (apiKey == null || apiKey.trim().isEmpty) {
        throw Exception('Gemini API key missing. Reconnect your key.');
      }

      final prompt = _buildPrompt(profile);
      final quote = await _quoteService.generateQuote(
        apiKey: apiKey,
        prompt: prompt,
      );

      state = state.copyWith(
        quote: quote,
        isLoading: false,
        profileSignature: signature,
        errorMessage: null,
      );
    } catch (e) {
      final fallbackQuote = _buildFallbackQuote(profile);
      state = state.copyWith(
        quote: fallbackQuote,
        isLoading: false,
        profileSignature: signature,
        errorMessage: null,
      );
    }
  }

  String _signatureFor(UserProfile profile) {
    return '${profile.name}|${profile.age}|${profile.weightKg}|${profile.heightCm}|${profile.healthGoal}';
  }

  String _buildPrompt(UserProfile profile) {
    return '''
Create one short, personal, uplifting fitness motivation quote.
Requirements:
- Max 22 words.
- Directly address the user by first name.
- Make it specific to their goal and profile.
- Sound human, warm, and practical.
- Plain text only. No markdown. No label.

User profile:
- Name: ${profile.name}
- Age: ${profile.age}
- Weight (kg): ${profile.weightKg}
- Height (cm): ${profile.heightCm}
- Goal: ${profile.healthGoal}
''';
  }

  String _buildFallbackQuote(UserProfile profile) {
    final goal = profile.healthGoal.trim().toLowerCase();
    final name = profile.name.trim().isEmpty ? 'Athlete' : profile.name.trim();

    if (goal.contains('weight') ||
        goal.contains('fat') ||
        goal.contains('loss')) {
      return '$name, every light meal and every walk today is proof you are already becoming leaner and stronger.';
    }

    if (goal.contains('muscle') ||
        goal.contains('gain') ||
        goal.contains('strength')) {
      return '$name, each rep and each protein-rich meal is building the stronger body you said you wanted.';
    }

    if (goal.contains('endurance') || goal.contains('stamina')) {
      return '$name, consistency today builds tomorrow\'s stamina, keep your pace and trust your progress.';
    }

    return '$name, small consistent choices today will shape your fitness journey more than any perfect single day.';
  }
}
