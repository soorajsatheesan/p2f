import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2f/models/weight_entry.dart';
import 'package:p2f/services/weight_storage_service.dart';

final weightStorageProvider = Provider<WeightStorageService>(
  (_) => WeightStorageService(),
);

final weightProvider =
    StateNotifierProvider<WeightNotifier, WeightState>((ref) {
      return WeightNotifier(ref.read(weightStorageProvider));
    });

// ── State ──────────────────────────────────────────────────────────────────────

class WeightState {
  const WeightState({
    this.entries = const [],
    this.isLoading = false,
    this.isSaving = false,
  });

  final List<WeightEntry> entries;
  final bool isLoading;
  final bool isSaving;

  // Sorted ascending
  List<WeightEntry> get sortedEntries {
    final list = [...entries];
    list.sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
    return list;
  }

  // One entry per day (latest wins), last 14 days max — used for chart
  List<WeightEntry> get chartEntries {
    final byDay = <String, WeightEntry>{};
    for (final e in sortedEntries) {
      final key =
          '${e.loggedAt.year}-${e.loggedAt.month.toString().padLeft(2, '0')}-${e.loggedAt.day.toString().padLeft(2, '0')}';
      byDay[key] = e;
    }
    final list = byDay.values.toList()
      ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
    return list.length > 14 ? list.sublist(list.length - 14) : list;
  }

  bool get hasLoggedToday {
    final t = DateTime.now();
    return entries.any(
      (e) =>
          e.loggedAt.year == t.year &&
          e.loggedAt.month == t.month &&
          e.loggedAt.day == t.day,
    );
  }

  double? get latestWeight =>
      sortedEntries.isEmpty ? null : sortedEntries.last.weightKg;

  // Change vs ~7 days ago (negative = good)
  double? get weekChange {
    final sorted = sortedEntries;
    if (sorted.length < 2) return null;
    final latest = sorted.last.weightKg;
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    // Walk backwards to find the closest entry at or before 7 days ago
    WeightEntry? ref;
    for (final e in sorted.reversed) {
      if (e.loggedAt.isBefore(cutoff) ||
          e.loggedAt.difference(cutoff).inHours.abs() < 24) {
        ref = e;
        break;
      }
    }
    if (ref == null) {
      // Fallback: just use the oldest entry
      ref = sorted.length >= 2 ? sorted.first : null;
    }
    if (ref == null) return null;
    return latest - ref.weightKg;
  }

  // Consecutive days with a log (counting back from today or yesterday)
  int get streak {
    final chart = chartEntries;
    if (chart.isEmpty) return 0;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final loggedDates = chart
        .map((e) => DateTime(e.loggedAt.year, e.loggedAt.month, e.loggedAt.day))
        .toSet();
    final start =
        loggedDates.contains(todayDate)
            ? todayDate
            : todayDate.subtract(const Duration(days: 1));
    int count = 0;
    DateTime check = start;
    while (loggedDates.contains(check)) {
      count++;
      check = check.subtract(const Duration(days: 1));
    }
    return count;
  }

  // Total unique days logged
  int get totalDaysLogged {
    final byDay = <String>{};
    for (final e in entries) {
      byDay.add(
        '${e.loggedAt.year}-${e.loggedAt.month}-${e.loggedAt.day}',
      );
    }
    return byDay.length;
  }

  WeightState copyWith({
    List<WeightEntry>? entries,
    bool? isLoading,
    bool? isSaving,
  }) => WeightState(
    entries: entries ?? this.entries,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
  );
}

// ── Notifier ───────────────────────────────────────────────────────────────────

class WeightNotifier extends StateNotifier<WeightState> {
  WeightNotifier(this._storage) : super(const WeightState()) {
    _load();
  }

  final WeightStorageService _storage;

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    final entries = await _storage.getEntries();
    state = state.copyWith(entries: entries, isLoading: false);
  }

  Future<void> logWeight(double kg) async {
    state = state.copyWith(isSaving: true);
    final entry = await _storage.insertEntry(kg);
    state = state.copyWith(
      entries: [...state.entries, entry],
      isSaving: false,
    );
  }

  Future<void> clear() async {
    await _storage.clearEntries();
    state = const WeightState();
  }
}

