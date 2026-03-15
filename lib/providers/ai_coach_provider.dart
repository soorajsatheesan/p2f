import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2f/models/chat_message.dart';
import 'package:p2f/models/user_profile.dart';
import 'package:p2f/providers/login_provider.dart';
import 'package:p2f/services/ai_chat_history_storage_service.dart';
import 'package:p2f/services/ai_coach_service.dart';
import 'package:p2f/services/secure_storage_service.dart';

// ── Companion model ───────────────────────────────────────────────────────────

class Companion {
  const Companion({
    required this.id,
    required this.name,
    required this.specialty,
    required this.personality,
    required this.description,
    required this.icon,
    required this.imagePath,
    required this.greeting,
    required this.systemPersona,
  });

  final String id;
  final String name;
  final String specialty;
  final String personality;
  final String description;
  final IconData icon;
  final String imagePath;
  final String greeting;
  final String systemPersona;

  static const zeus = Companion(
    id: 'zeus',
    name: 'Zeus',
    specialty: 'Strength & Power',
    personality: 'Commanding and relentless',
    description:
        'Drives you to new peaks with intense strength programs and explosive power.',
    icon: Icons.bolt_rounded,
    imagePath: 'assets/images/companions/Zeus.png',
    greeting:
        'Zeus speaks. You are here to get stronger. Tell me what you want to conquer — strength, power, muscle. Make your ask.',
    systemPersona:
        'You are Zeus, a commanding and relentless strength and power coach. '
        'Your tone is intense, motivating, and uncompromising. '
        'You specialize in heavy lifting, powerlifting, explosive performance training, and muscle building. '
        'Be direct and concise. Push the user hard but always keep advice safe and practical.',
  );

  static const hades = Companion(
    id: 'hades',
    name: 'Hades',
    specialty: 'Endurance & Grit',
    personality: 'Unyielding and disciplined',
    description:
        'Forges iron mental toughness and stamina through grueling endurance protocols.',
    icon: Icons.dark_mode_rounded,
    imagePath: 'assets/images/companions/Hades.png',
    greeting:
        'Weakness is a choice. Tell me where you stand — your endurance baseline, your goal — and we build from there.',
    systemPersona:
        'You are Hades, an unyielding and disciplined endurance coach. '
        'Your tone is stoic, serious, and relentless. '
        'You specialize in endurance, stamina building, mental resilience coaching, and high-intensity protocols. '
        'Never sugar-coat. Demand discipline. Be concise and practical.',
  );

  static const athena = Companion(
    id: 'athena',
    name: 'Athena',
    specialty: 'Strategy & Nutrition',
    personality: 'Wise and precise',
    description:
        'Builds science-backed fitness plans and optimizes your nutrition timing with data.',
    icon: Icons.shield_rounded,
    imagePath: 'assets/images/companions/Athena.png',
    greeting:
        'Precision matters. Share your situation — training schedule, diet, goals — and I will build you a plan that works.',
    systemPersona:
        'You are Athena, a wise and precise strategy and nutrition coach. '
        'Your tone is analytical, methodical, and evidence-based. '
        'You specialize in nutrition strategy and timing, periodization planning, recovery optimization, and data-driven guidance. '
        'Give thorough, science-backed answers. Be concise when possible.',
  );

  static const aphrodite = Companion(
    id: 'aphrodite',
    name: 'Aphrodite',
    specialty: 'Wellness & Balance',
    personality: 'Balanced and nurturing',
    description:
        'Focuses on holistic wellness, body composition, flexibility, and lasting habits.',
    icon: Icons.favorite_rounded,
    imagePath: 'assets/images/companions/Aphrodite.png',
    greeting:
        'Let\'s build something that lasts. Tell me how you\'re feeling and what balance looks like to you right now.',
    systemPersona:
        'You are Aphrodite, a balanced and nurturing wellness coach. '
        'Your tone is warm, encouraging, and holistic. '
        'You specialize in body composition and toning, flexibility and mobility, sustainable lifestyle habits, and long-term wellness. '
        'Focus on balance and sustainability. Be kind but practical.',
  );

  static const all = [zeus, hades, athena, aphrodite];
}

// ── Provider ──────────────────────────────────────────────────────────────────

final aiCoachServiceProvider = Provider<AiCoachService>((ref) {
  return AiCoachService();
});

final aiChatHistoryStorageProvider = Provider<AiChatHistoryStorageService>((ref) {
  return AiChatHistoryStorageService();
});

final aiCoachProvider = StateNotifierProvider<AiCoachNotifier, AiCoachState>((
  ref,
) {
  return AiCoachNotifier(
    coachService: ref.read(aiCoachServiceProvider),
    chatHistoryStorage: ref.read(aiChatHistoryStorageProvider),
    secureStorage: ref.read(secureStorageProvider),
  );
});

// ── State ─────────────────────────────────────────────────────────────────────

class AiCoachState {
  const AiCoachState({
    this.messages = const [],
    this.isSending = false,
    this.isLoadingHistory = false,
    this.errorMessage,
    this.activeCompanion,
  });

  final List<ChatMessage> messages;
  final bool isSending;
  final bool isLoadingHistory;
  final String? errorMessage;
  final Companion? activeCompanion;

  bool get hasCompanion => activeCompanion != null;

  AiCoachState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    bool? isLoadingHistory,
    Object? errorMessage = _sentinel,
    Object? activeCompanion = _sentinel,
  }) {
    return AiCoachState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      activeCompanion: identical(activeCompanion, _sentinel)
          ? this.activeCompanion
          : activeCompanion as Companion?,
    );
  }
}

const Object _sentinel = Object();

// ── Notifier ──────────────────────────────────────────────────────────────────

class AiCoachNotifier extends StateNotifier<AiCoachState> {
  AiCoachNotifier({
    required AiCoachService coachService,
    required AiChatHistoryStorageService chatHistoryStorage,
    required SecureStorageService secureStorage,
  }) : _coachService = coachService,
       _chatHistoryStorage = chatHistoryStorage,
       _secureStorage = secureStorage,
       super(const AiCoachState());

  final AiCoachService _coachService;
  final AiChatHistoryStorageService _chatHistoryStorage;
  final SecureStorageService _secureStorage;
  int _conversationVersion = 0;
  final Map<String, List<ChatMessage>> _historyCache = {};

  Future<void> selectCompanion(Companion companion) async {
    _conversationVersion++;
    final selectionVersion = _conversationVersion;

    state = AiCoachState(
      activeCompanion: companion,
      isLoadingHistory: true,
    );

    final cachedHistory = _historyCache[companion.id];
    if (cachedHistory != null) {
      if (!_isCurrentConversation(
        version: selectionVersion,
        companionId: companion.id,
      )) {
        return;
      }
      state = state.copyWith(
        messages: cachedHistory,
        isLoadingHistory: false,
        errorMessage: null,
      );
      return;
    }

    var history = await _chatHistoryStorage.getMessages(companion.id);
    if (history.isEmpty) {
      final greeting = _buildGreeting(companion);
      await _chatHistoryStorage.insertMessage(
        companionId: companion.id,
        message: greeting,
      );
      history = [greeting];
    }

    if (!_isCurrentConversation(
      version: selectionVersion,
      companionId: companion.id,
    )) {
      return;
    }

    final immutableHistory = List<ChatMessage>.unmodifiable(history);
    _historyCache[companion.id] = immutableHistory;
    state = state.copyWith(
      messages: immutableHistory,
      isLoadingHistory: false,
      errorMessage: null,
    );
  }

  void clearCompanion() {
    _conversationVersion++;
    state = const AiCoachState();
  }

  Future<void> sendMessage({
    required String userText,
    required UserProfile? profile,
  }) async {
    final trimmed = userText.trim();
    if (trimmed.isEmpty || state.isSending) return;
    final companion = state.activeCompanion;
    if (companion == null) return;
    final requestVersion = _conversationVersion;

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
      isLoadingHistory: false,
      errorMessage: null,
    );

    try {
      _cacheHistory(companion.id, updated);
      await _chatHistoryStorage.insertMessage(
        companionId: companion.id,
        message: updated.last,
      );

      final key = await _secureStorage.getApiKey(StorageKeys.apiToken);
      if (key == null || key.trim().isEmpty) {
        throw Exception('OpenAI API key missing. Reconnect in Profile.');
      }

      final prompt = _buildPrompt(
        companion: companion,
        latestUserMessage: trimmed,
        profile: profile,
        history: updated,
      );

      final reply = await _coachService.getReply(apiKey: key, prompt: prompt);
      final assistantMessage = ChatMessage(
        role: ChatRole.assistant,
        text: reply,
        createdAt: DateTime.now(),
      );
      final nextMessages = [...updated, assistantMessage];
      _cacheHistory(companion.id, nextMessages);
      await _chatHistoryStorage.insertMessage(
        companionId: companion.id,
        message: assistantMessage,
      );
      if (!_isCurrentConversation(
        version: requestVersion,
        companionId: companion.id,
      )) {
        return;
      }
      state = state.copyWith(
        isSending: false,
        messages: nextMessages,
      );
    } catch (e) {
      if (!_isCurrentConversation(
        version: requestVersion,
        companionId: companion.id,
      )) {
        return;
      }
      state = state.copyWith(
        isSending: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> resetConversation() async {
    _conversationVersion++;
    _historyCache.clear();
    await _chatHistoryStorage.clearAllHistory();
    state = const AiCoachState();
  }

  bool _isCurrentConversation({
    required int version,
    required String? companionId,
  }) {
    return _conversationVersion == version &&
        state.activeCompanion?.id == companionId;
  }

  ChatMessage _buildGreeting(Companion companion) {
    return ChatMessage(
      role: ChatRole.assistant,
      text: companion.greeting,
      createdAt: DateTime.now(),
    );
  }

  void _cacheHistory(String companionId, List<ChatMessage> messages) {
    _historyCache[companionId] = List<ChatMessage>.unmodifiable(messages);
  }

  String _buildPrompt({
    required Companion? companion,
    required String latestUserMessage,
    required UserProfile? profile,
    required List<ChatMessage> history,
  }) {
    final persona = companion?.systemPersona ??
        'You are an AI health and fitness assistant. Be concise and practical.';

    final profileBlock = profile == null
        ? 'User profile: not available.'
        : 'User profile: name=${profile.name}, age=${profile.age}, '
          'weight_kg=${profile.weightKg}, height_cm=${profile.heightCm}, '
          'goals=${profile.healthGoals.join(', ')}.';

    final companionName = companion?.name ?? 'Assistant';
    final recentHistory = history.length > 10
        ? history.sublist(history.length - 10)
        : history;

    final convo = recentHistory
        .map(
          (m) =>
              '${m.role == ChatRole.user ? 'User' : companionName}: ${m.text}',
        )
        .join('\n');

    return '''
$persona
Scope: only fitness, exercise, nutrition, recovery, sleep, and body-composition guidance.
If asked about anything outside this scope, politely decline in one short sentence and redirect to health and fitness.
Never claim to diagnose disease. For medical symptoms, advise consulting a qualified professional.
Use the user's profile context when relevant.
If the user has not given enough context to answer well or safely, do not guess.
Instead, ask 1 to 3 short, specific follow-up questions that will let you answer properly.
When key details are missing, prioritize questions over advice.
Only give a full recommendation once you have enough context from the user or their profile.
Formatting: respond in plain text only. Do not use markdown, bold markers, asterisks, code blocks, or headings.
$profileBlock

Conversation so far:
$convo

Latest user message:
$latestUserMessage
''';
  }
}
