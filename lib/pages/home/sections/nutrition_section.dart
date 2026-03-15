import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2f/models/nutrition_entry.dart';
import 'package:p2f/providers/nutrition_provider.dart';
import 'package:p2f/theme/theme.dart';
import 'package:p2f/widgets/global/global_widgets.dart';

class NutritionSection extends ConsumerWidget {
  const NutritionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nutritionProvider);
    final selectedEntries = state.selectedDayEntries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Compact hero ──────────────────────────────────────────────────────
        const _NutritionHero(),

        const SizedBox(height: 28),
        const Divider(height: 1, thickness: 1, color: AppColors.border),
        const SizedBox(height: 24),

        // ── Date + intake in one block ────────────────────────────────────────
        _IntakeBlock(state: state),

        const SizedBox(height: 28),
        const Divider(height: 1, thickness: 1, color: AppColors.border),
        const SizedBox(height: 24),

        // ── Meal log ─────────────────────────────────────────────────────────
        _MealLog(state: state, entries: selectedEntries),

        const SizedBox(height: 80),
      ],
    );
  }
}

// ── Compact Hero ──────────────────────────────────────────────────────────────

class _NutritionHero extends StatelessWidget {
  const _NutritionHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NUTRITION',
          style: AppTypography.tag.copyWith(
            color: AppColors.subtle,
            letterSpacing: 2.5,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Fuel. Log. Repeat.',
          style: AppTypography.displaySmall.copyWith(
            fontSize: 36,
            height: 1.0,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 3,
              height: 3,
              decoration: const BoxDecoration(
                color: AppColors.faint,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Photograph any meal · AI breaks down your macros instantly.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.subtle,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Intake block (date selector + macros) ─────────────────────────────────────

class _IntakeBlock extends ConsumerWidget {
  const _IntakeBlock({required this.state});

  final NutritionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = state.effectiveSelectedDay;
    final isEmpty = state.selectedDayEntries.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Date selector row ──
        Row(
          children: [
            Text(
              'INTAKE',
              style: AppTypography.tag.copyWith(
                color: AppColors.faint,
                letterSpacing: 2,
                fontSize: 10,
              ),
            ),
            const Spacer(),
            _DateChip(day: selectedDay, state: state),
          ],
        ),

        const SizedBox(height: 18),

        // ── Big calorie number ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnimatedStatNumber(
              value: state.selectedDayTotalCalories,
              style: AppTypography.statValue.copyWith(
                fontSize: 54,
                letterSpacing: -2,
              ),
              duration: const Duration(milliseconds: 900),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'kcal',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.subtle,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),

        if (isEmpty) ...[
          const SizedBox(height: 5),
          Text(
            'Nothing logged yet — tap + to capture your first meal.',
            style: AppTypography.bodySmall,
          ),
        ],

        const SizedBox(height: 20),

        // ── Macro row ──
        IntrinsicHeight(
          child: Row(
            children: [
              _MacroItem(label: 'Protein', value: state.selectedDayProteinG),
              _MacroSplit(),
              _MacroItem(label: 'Carbs', value: state.selectedDayCarbsG),
              _MacroSplit(),
              _MacroItem(label: 'Fats', value: state.selectedDayFatsG),
              _MacroSplit(),
              _MacroItem(label: 'Fiber', value: state.selectedDayFiberG),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Date chip ─────────────────────────────────────────────────────────────────

class _DateChip extends ConsumerWidget {
  const _DateChip({required this.day, required this.state});

  final DateTime day;
  final NutritionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => _openCalendar(context, ref),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.borderStrong),
          color: AppColors.surface,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 13,
              color: AppColors.subtle,
            ),
            const SizedBox(width: 7),
            Text(
              _formatChipLabel(day),
              style: AppTypography.labelLarge.copyWith(fontSize: 13),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppColors.subtle,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCalendar(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CalendarSheet(state: state),
    );
  }

  String _formatChipLabel(DateTime d) {
    final now = DateTime.now();
    if (_isSameDay(d, now)) return 'Today';
    if (_isSameDay(d, now.subtract(const Duration(days: 1)))) return 'Yesterday';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }
}

// ── Calendar bottom sheet ─────────────────────────────────────────────────────

class _CalendarSheet extends ConsumerStatefulWidget {
  const _CalendarSheet({required this.state});

  final NutritionState state;

  @override
  ConsumerState<_CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends ConsumerState<_CalendarSheet> {
  late DateTime _viewMonth;

  @override
  void initState() {
    super.initState();
    final sel = widget.state.effectiveSelectedDay;
    _viewMonth = DateTime(sel.year, sel.month);
  }

  bool _canGoForward() {
    final now = DateTime.now();
    return _viewMonth.year < now.year ||
        (_viewMonth.year == now.year && _viewMonth.month < now.month);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionProvider);
    final today = _dateOnly(DateTime.now());
    final selectedDay = state.effectiveSelectedDay;

    final firstDay = DateTime(_viewMonth.year, _viewMonth.month, 1);
    final daysInMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;
    final leadingEmpty = firstDay.weekday - 1; // Mon = 0

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.overlayFade,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Month nav
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() {
                      _viewMonth =
                          DateTime(_viewMonth.year, _viewMonth.month - 1);
                    }),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.subtle,
                        size: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _formatMonthYear(_viewMonth),
                      style: AppTypography.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: _canGoForward()
                        ? () => setState(() {
                              _viewMonth = DateTime(
                                _viewMonth.year,
                                _viewMonth.month + 1,
                              );
                            })
                        : null,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: _canGoForward()
                            ? AppColors.subtle
                            : AppColors.faint,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Weekday headers
              Row(
                children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                    .map(
                      (d) => Expanded(
                        child: Text(
                          d,
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 10,
                            color: AppColors.faint,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),

              // Day grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                  mainAxisSpacing: 2,
                ),
                itemCount: leadingEmpty + daysInMonth,
                itemBuilder: (context, index) {
                  if (index < leadingEmpty) return const SizedBox.shrink();

                  final day = DateTime(
                    _viewMonth.year,
                    _viewMonth.month,
                    index - leadingEmpty + 1,
                  );
                  final isFuture = day.isAfter(today);
                  final isSelected = _isSameDay(day, selectedDay);
                  final isToday = _isSameDay(day, today);
                  final hasEntry = state.entries
                      .any((e) => _isSameDay(e.createdAt, day));

                  return GestureDetector(
                    onTap: isFuture
                        ? null
                        : () {
                            ref
                                .read(nutritionProvider.notifier)
                                .selectDay(day);
                            Navigator.of(context).pop();
                          },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.foreground
                                : Colors.transparent,
                            border: isToday && !isSelected
                                ? Border.all(color: AppColors.borderStrong)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: AppTypography.bodySmall.copyWith(
                                color: isFuture
                                    ? AppColors.faint
                                    : (isSelected
                                        ? AppColors.background
                                        : AppColors.foreground),
                                fontSize: 13,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasEntry
                                ? (isSelected
                                    ? AppColors.background
                                    : AppColors.muted)
                                : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Macro row ─────────────────────────────────────────────────────────────────

class _MacroItem extends StatelessWidget {
  const _MacroItem({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.faint,
              fontSize: 9,
              letterSpacing: 1.2,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value.toStringAsFixed(1),
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.foreground,
                    fontSize: 16,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: ' g',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.subtle,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroSplit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: AppColors.border,
    );
  }
}

// ── Meal log ──────────────────────────────────────────────────────────────────

class _MealLog extends StatelessWidget {
  const _MealLog({required this.state, required this.entries});

  final NutritionState state;
  final List<NutritionEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MEAL LOG',
          style: AppTypography.tag.copyWith(
            color: AppColors.faint,
            letterSpacing: 2,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _formatMealsHeading(state.effectiveSelectedDay),
          style: AppTypography.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          entries.isEmpty
              ? 'Nothing recorded. Tap + to photograph and analyse a meal.'
              : '${entries.length} meal${entries.length == 1 ? '' : 's'} · ${state.selectedDayTotalCalories} kcal total',
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: 20),
        if (state.isLoadingHistory)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.subtle),
                ),
              ),
            ),
          )
        else if (entries.isEmpty)
          _EmptyMealSlot()
        else
          Column(
            children: entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MealTile(entry: entry),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _EmptyMealSlot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        color: AppColors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.add_photo_alternate_outlined,
            size: 24,
            color: AppColors.faint,
          ),
          const SizedBox(height: 12),
          Text('Nothing captured yet.', style: AppTypography.titleSmall),
          const SizedBox(height: 4),
          Text(
            'Tap + to photograph a meal. AI breaks down calories and macros instantly.',
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ── Meal tile ─────────────────────────────────────────────────────────────────

class _MealTile extends ConsumerStatefulWidget {
  const _MealTile({required this.entry});

  final NutritionEntry entry;

  @override
  ConsumerState<_MealTile> createState() => _MealTileState();
}

class _MealTileState extends ConsumerState<_MealTile> {
  bool _expanded = false;

  Future<void> _confirmDelete() async {
    final id = widget.entry.id;
    if (id == null) return;
    final shouldDelete = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeleteConfirmSheet(entry: widget.entry),
    );
    if (shouldDelete == true) {
      await ref.read(nutritionProvider.notifier).deleteEntry(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surface,
          border: Border.all(
            color: _expanded ? AppColors.borderStrong : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Main row ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(entry.imagePath),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.analysis.mealName,
                          style: AppTypography.titleSmall.copyWith(
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            // Calorie badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: AppColors.surfaceElevated,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                '${entry.analysis.calories} kcal',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.foreground,
                                  fontSize: 11,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatMealTime(entry.createdAt),
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Delete + chevron
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _confirmDelete,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: AppColors.faint,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: AppColors.subtle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Expanded macros ───────────────────────────────────────────────
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 220),
              firstCurve: Curves.easeOutCubic,
              secondCurve: Curves.easeInCubic,
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.border,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Macro row
                        Row(
                          children: [
                            _InlineMacro(
                              label: 'Protein',
                              value:
                                  '${entry.analysis.proteinG.toStringAsFixed(1)} g',
                            ),
                            const SizedBox(width: 16),
                            _InlineMacro(
                              label: 'Carbs',
                              value:
                                  '${entry.analysis.carbsG.toStringAsFixed(1)} g',
                            ),
                            const SizedBox(width: 16),
                            _InlineMacro(
                              label: 'Fats',
                              value:
                                  '${entry.analysis.fatsG.toStringAsFixed(1)} g',
                            ),
                            const SizedBox(width: 16),
                            _InlineMacro(
                              label: 'Fiber',
                              value:
                                  '${entry.analysis.fiberG.toStringAsFixed(1)} g',
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          entry.analysis.summary,
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineMacro extends StatelessWidget {
  const _InlineMacro({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.faint,
            fontSize: 9,
            letterSpacing: 0.8,
            height: 1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            fontSize: 13,
            height: 1,
          ),
        ),
      ],
    );
  }
}

// ── Delete confirm sheet ──────────────────────────────────────────────────────

class _DeleteConfirmSheet extends StatelessWidget {
  const _DeleteConfirmSheet({required this.entry});

  final NutritionEntry entry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.overlayFade,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal preview row
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(entry.imagePath),
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.analysis.mealName,
                          style: AppTypography.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${entry.analysis.calories} kcal',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              const SizedBox(height: 20),

              // Warning
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Color(0xFFFF4444),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This meal will be permanently removed from your nutrition history. This cannot be undone.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.subtle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                          color: AppColors.surface,
                        ),
                        child: Center(
                          child: Text(
                            'CANCEL',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.subtle,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(true),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: const Color(0xFF1A0505),
                          border: Border.all(
                            color: const Color(0x55FF4444),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'DELETE',
                            style: AppTypography.labelLarge.copyWith(
                              color: const Color(0xFFFF4444),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _formatMealsHeading(DateTime day) {
  if (_isSameDay(day, DateTime.now())) return "Today's meals";
  if (_isSameDay(day, DateTime.now().subtract(const Duration(days: 1)))) {
    return "Yesterday's meals";
  }
  return 'Meals on ${_formatShortDate(day)}';
}

String _formatShortDate(DateTime day) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[day.month - 1]} ${day.day}';
}

String _formatMonthYear(DateTime d) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return '${months[d.month - 1]} ${d.year}';
}

String _formatMealTime(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final suffix = time.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}

DateTime _dateOnly(DateTime date) =>
    DateTime(date.year, date.month, date.day);

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
