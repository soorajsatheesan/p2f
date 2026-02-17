import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2f/models/nutrition_analysis.dart';
import 'package:p2f/models/nutrition_entry.dart';
import 'package:p2f/providers/login_provider.dart';
import 'package:p2f/services/nutrition_ai_service.dart';
import 'package:p2f/services/nutrition_storage_service.dart';
import 'package:p2f/services/secure_storage_service.dart';

final nutritionAiServiceProvider = Provider<NutritionAiService>((ref) {
  return NutritionAiService();
});

final nutritionStorageProvider = Provider<NutritionStorageService>((ref) {
  return NutritionStorageService();
});

final nutritionProvider =
    StateNotifierProvider<NutritionNotifier, NutritionState>((ref) {
      return NutritionNotifier(
        aiService: ref.read(nutritionAiServiceProvider),
        storageService: ref.read(nutritionStorageProvider),
        secureStorage: ref.read(secureStorageProvider),
      );
    });

class NutritionState {
  const NutritionState({
    this.entries = const [],
    this.lastAnalysis,
    this.isLoadingHistory = true,
    this.isAnalyzing = false,
    this.errorMessage,
  });

  final List<NutritionEntry> entries;
  final NutritionAnalysis? lastAnalysis;
  final bool isLoadingHistory;
  final bool isAnalyzing;
  final String? errorMessage;

  NutritionState copyWith({
    List<NutritionEntry>? entries,
    NutritionAnalysis? lastAnalysis,
    bool clearLastAnalysis = false,
    bool? isLoadingHistory,
    bool? isAnalyzing,
    Object? errorMessage = _sentinel,
  }) {
    return NutritionState(
      entries: entries ?? this.entries,
      lastAnalysis: clearLastAnalysis
          ? null
          : (lastAnalysis ?? this.lastAnalysis),
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _sentinel = Object();

class NutritionNotifier extends StateNotifier<NutritionState> {
  NutritionNotifier({
    required NutritionAiService aiService,
    required NutritionStorageService storageService,
    required SecureStorageService secureStorage,
  }) : _aiService = aiService,
       _storageService = storageService,
       _secureStorage = secureStorage,
       super(const NutritionState()) {
    loadHistory();
  }

  final NutritionAiService _aiService;
  final NutritionStorageService _storageService;
  final SecureStorageService _secureStorage;

  Future<void> loadHistory() async {
    state = state.copyWith(isLoadingHistory: true, errorMessage: null);
    try {
      final entries = await _storageService.getEntries();
      state = state.copyWith(entries: entries, isLoadingHistory: false);
    } catch (_) {
      state = state.copyWith(
        isLoadingHistory: false,
        errorMessage: 'Failed to load nutrition history.',
      );
    }
  }

  Future<void> analyzeAndSave({
    required String imagePath,
    required String description,
  }) async {
    state = state.copyWith(isAnalyzing: true, errorMessage: null);

    try {
      final key = await _secureStorage.getApiKey(StorageKeys.apiToken);
      if (key == null || key.trim().isEmpty) {
        throw Exception('Gemini API key not found. Please reconnect key.');
      }

      final imageFile = File(imagePath);
      final bytes = await imageFile.readAsBytes();
      final mimeType = _mimeTypeFromPath(imagePath);

      final analysis = await _aiService.analyzeMeal(
        apiKey: key,
        imageBytes: bytes,
        mimeType: mimeType,
        description: description.trim(),
      );

      final entry = NutritionEntry(
        imagePath: imagePath,
        description: description.trim(),
        createdAt: DateTime.now(),
        analysis: analysis,
      );

      final stored = await _storageService.insertEntry(entry);
      final updatedEntries = [stored, ...state.entries];

      state = state.copyWith(
        entries: updatedEntries,
        lastAnalysis: analysis,
        isAnalyzing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  String _mimeTypeFromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }
}
