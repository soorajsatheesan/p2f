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
    this.selectedDay,
  });

  final List<NutritionEntry> entries;
  final NutritionAnalysis? lastAnalysis;
  final bool isLoadingHistory;
  final bool isAnalyzing;
  final String? errorMessage;
  final DateTime? selectedDay;

  DateTime get effectiveSelectedDay => _dateOnly(selectedDay ?? DateTime.now());

  List<NutritionEntry> get selectedDayEntries {
    final day = effectiveSelectedDay;
    return entries.where((entry) => _isSameDay(entry.createdAt, day)).toList();
  }

  List<DateTime> get availableDays {
    final seen = <String>{};
    final days = <DateTime>[];
    for (final entry in entries) {
      final day = _dateOnly(entry.createdAt);
      final key = day.toIso8601String();
      if (seen.add(key)) {
        days.add(day);
      }
    }
    return days;
  }

  bool get hasEntriesForSelectedDay => selectedDayEntries.isNotEmpty;

  int get selectedDayTotalCalories => selectedDayEntries.fold<int>(
    0,
    (sum, entry) => sum + entry.analysis.calories,
  );

  double get selectedDayProteinG =>
      _selectedDayMacroTotal((entry) => entry.analysis.proteinG);

  double get selectedDayCarbsG =>
      _selectedDayMacroTotal((entry) => entry.analysis.carbsG);

  double get selectedDayFatsG =>
      _selectedDayMacroTotal((entry) => entry.analysis.fatsG);

  double get selectedDayFiberG =>
      _selectedDayMacroTotal((entry) => entry.analysis.fiberG);

  double _selectedDayMacroTotal(double Function(NutritionEntry entry) pick) {
    return selectedDayEntries.fold<double>(0, (sum, entry) => sum + pick(entry));
  }

  NutritionState copyWith({
    List<NutritionEntry>? entries,
    NutritionAnalysis? lastAnalysis,
    bool clearLastAnalysis = false,
    bool? isLoadingHistory,
    bool? isAnalyzing,
    Object? errorMessage = _sentinel,
    Object? selectedDay = _sentinel,
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
      selectedDay: identical(selectedDay, _sentinel)
          ? this.selectedDay
          : selectedDay as DateTime?,
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
      state = state.copyWith(
        entries: entries,
        isLoadingHistory: false,
        selectedDay: _resolveSelectedDay(entries, state.selectedDay),
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingHistory: false,
        errorMessage: 'Failed to load nutrition history.',
      );
    }
  }

  Future<NutritionEntry?> analyzeAndSave({
    required String imagePath,
    required String description,
  }) async {
    state = state.copyWith(isAnalyzing: true, errorMessage: null);

    try {
      final key = await _secureStorage.getApiKey(StorageKeys.apiToken);
      if (key == null || key.trim().isEmpty) {
        throw Exception('OpenAI API key not found. Please reconnect key.');
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
        selectedDay: _resolveSelectedDay(updatedEntries, DateTime.now()),
      );
      return stored;
    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  Future<void> deleteEntry(int id) async {
    try {
      await _storageService.deleteEntry(id);
      final updatedEntries = state.entries.where((e) => e.id != id).toList();
      state = state.copyWith(
        entries: updatedEntries,
        selectedDay: _resolveSelectedDay(updatedEntries, state.selectedDay),
      );
    } catch (_) {
      state = state.copyWith(errorMessage: 'Failed to delete meal entry.');
    }
  }

  void selectDay(DateTime day) {
    state = state.copyWith(selectedDay: _dateOnly(day), errorMessage: null);
  }

  Future<void> clearSessionData() async {
    try {
      await _storageService.clearEntries();
    } finally {
      state = NutritionState(
        isLoadingHistory: false,
        selectedDay: _dateOnly(DateTime.now()),
      );
    }
  }

  DateTime _resolveSelectedDay(
    List<NutritionEntry> entries,
    DateTime? preferredDay,
  ) {
    final normalizedPreferred = _dateOnly(preferredDay ?? DateTime.now());
    if (entries.any((entry) => _isSameDay(entry.createdAt, normalizedPreferred))) {
      return normalizedPreferred;
    }
    return normalizedPreferred;
  }

  String _mimeTypeFromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
