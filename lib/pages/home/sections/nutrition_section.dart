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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ZenCard(
          radius: 24,
          backgroundColor: isDark ? const Color(0xFF1A2438) : AppColors.surface,
          borderColor: isDark
              ? const Color(0xFF2D3E61)
              : const Color(0xFFD8E2F8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nutrition',
                style: AppTypography.headlineSmall.copyWith(
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Today\'s total calories',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.gray400 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${state.todayTotalCalories} kcal',
                style: AppTypography.displaySmall.copyWith(
                  fontSize: 34,
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Today's total macros",
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.gray400 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MacroChip(
                    label: 'Protein',
                    value: '${state.todayProteinG.toStringAsFixed(1)} g',
                  ),
                  _MacroChip(
                    label: 'Carbs',
                    value: '${state.todayCarbsG.toStringAsFixed(1)} g',
                  ),
                  _MacroChip(
                    label: 'Fats',
                    value: '${state.todayFatsG.toStringAsFixed(1)} g',
                  ),
                  _MacroChip(
                    label: 'Fiber',
                    value: '${state.todayFiberG.toStringAsFixed(1)} g',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ZenCard(
          radius: 24,
          backgroundColor: isDark ? const Color(0xFF1A2438) : AppColors.surface,
          borderColor: isDark
              ? const Color(0xFF2D3E61)
              : const Color(0xFFD8E2F8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meals',
                style: AppTypography.titleLarge.copyWith(
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              if (state.isLoadingHistory)
                const Center(child: CircularProgressIndicator())
              else if (state.entries.isEmpty)
                Text(
                  'No meals added yet. Tap + to analyze a meal.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.textSecondary,
                  ),
                )
              else
                Column(
                  children: state.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _MealTile(entry: entry),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MealTile extends ConsumerWidget {
  const _MealTile({required this.entry});

  final NutritionEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark ? AppColors.gray800 : AppColors.gray50,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(File(entry.imagePath)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          entry.analysis.mealName,
          style: AppTypography.labelLarge.copyWith(
            color: isDark ? AppColors.gray300 : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '${entry.analysis.calories} kcal',
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.gray400 : AppColors.textSecondary,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          color: AppColors.error,
          onPressed: () async {
            final id = entry.id;
            if (id == null) return;
            final shouldDelete = await showDialog<bool>(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  title: const Text('Delete meal entry?'),
                  content: const Text(
                    'This will remove this meal from your nutrition history.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );
            if (shouldDelete == true) {
              await ref.read(nutritionProvider.notifier).deleteEntry(id);
            }
          },
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MacroChip(
                  label: 'Protein',
                  value: '${entry.analysis.proteinG} g',
                ),
                _MacroChip(label: 'Carbs', value: '${entry.analysis.carbsG} g'),
                _MacroChip(label: 'Fats', value: '${entry.analysis.fatsG} g'),
                _MacroChip(label: 'Fiber', value: '${entry.analysis.fiberG} g'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              entry.analysis.summary,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isDark ? const Color(0xFF223250) : const Color(0xFFE8EFFF),
      ),
      child: Text(
        '$label: $value',
        style: AppTypography.labelSmall.copyWith(
          color: isDark ? const Color(0xFF9EBEFF) : AppColors.primary,
        ),
      ),
    );
  }
}
