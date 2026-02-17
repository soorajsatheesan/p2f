import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:p2f/models/nutrition_analysis.dart';
import 'package:p2f/models/nutrition_entry.dart';
import 'package:p2f/providers/nutrition_provider.dart';
import 'package:p2f/theme/theme.dart';
import 'package:p2f/widgets/global/global_widgets.dart';

class NutritionSection extends ConsumerStatefulWidget {
  const NutritionSection({super.key});

  @override
  ConsumerState<NutritionSection> createState() => _NutritionSectionState();
}

class _NutritionSectionState extends ConsumerState<NutritionSection> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();
  String? _imagePath;
  String? _descriptionError;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1400,
    );
    if (picked == null) return;

    setState(() {
      _imagePath = picked.path;
    });
  }

  Future<void> _analyze() async {
    final description = _descriptionController.text.trim();
    setState(() {
      _descriptionError = description.isEmpty
          ? 'Describe the meal briefly'
          : null;
    });

    if (_imagePath == null || description.isEmpty) return;

    await ref
        .read(nutritionProvider.notifier)
        .analyzeAndSave(imagePath: _imagePath!, description: description);

    final error = ref.read(nutritionProvider).errorMessage;
    if (error == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nutrition saved to local history.')),
      );
      setState(() {
        _imagePath = null;
        _descriptionController.clear();
        _descriptionError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'Image Nutrition Tracking',
                style: AppTypography.headlineSmall.copyWith(
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Take a meal image, add short context, get calories + macros from Gemini.',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.gray400 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              _ImagePreview(imagePath: _imagePath),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ZenSecondaryButton(
                      label: 'Take photo',
                      icon: Icons.camera_alt_rounded,
                      onPressed: state.isAnalyzing
                          ? null
                          : () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ZenSecondaryButton(
                      label: 'Choose image',
                      icon: Icons.photo_library_rounded,
                      onPressed: state.isAnalyzing
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ZenInputField(
                controller: _descriptionController,
                onChanged: (_) {
                  if (_descriptionError != null) {
                    setState(() {
                      _descriptionError = null;
                    });
                  }
                },
                labelText: 'Describe your meal',
                hintText: 'e.g. grilled chicken, rice, salad with olive oil',
                maxLines: 3,
                errorText: _descriptionError,
                enabled: !state.isAnalyzing,
              ),
              const SizedBox(height: 12),
              ZenPrimaryButton(
                label: state.isAnalyzing ? 'Analyzing...' : 'Analyze meal',
                isLoading: state.isAnalyzing,
                onPressed: state.isAnalyzing ? null : _analyze,
                icon: Icons.auto_awesome_rounded,
                backgroundColor: isDark
                    ? const Color(0xFF9EBEFF)
                    : AppColors.primary,
                foregroundColor: Colors.white,
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  state.errorMessage!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (state.lastAnalysis != null) ...[
          const SizedBox(height: 14),
          _AnalysisResultCard(analysis: state.lastAnalysis!),
        ],
        const SizedBox(height: 14),
        _HistoryList(isLoading: state.isLoadingHistory, entries: state.entries),
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? AppColors.gray800 : AppColors.gray50,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: imagePath == null
          ? Center(
              child: Text(
                'No image selected',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.gray500 : AppColors.textMuted,
                ),
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(
                File(imagePath!),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
    );
  }
}

class _AnalysisResultCard extends StatelessWidget {
  const _AnalysisResultCard({required this.analysis});

  final NutritionAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ZenCard(
      radius: 20,
      backgroundColor: isDark ? const Color(0xFF1A2438) : AppColors.surface,
      borderColor: isDark ? const Color(0xFF2D3E61) : const Color(0xFFD8E2F8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest analysis',
            style: AppTypography.titleLarge.copyWith(
              color: isDark ? AppColors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricChip(
                label: 'Calories',
                value: '${analysis.calories} kcal',
              ),
              _MetricChip(label: 'Protein', value: '${analysis.proteinG} g'),
              _MetricChip(label: 'Carbs', value: '${analysis.carbsG} g'),
              _MetricChip(label: 'Fats', value: '${analysis.fatsG} g'),
              _MetricChip(label: 'Fiber', value: '${analysis.fiberG} g'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            analysis.summary,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? AppColors.gray800 : AppColors.gray50,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Text(
        '$label: $value',
        style: AppTypography.labelMedium.copyWith(
          color: isDark ? AppColors.gray300 : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.isLoading, required this.entries});

  final bool isLoading;
  final List<NutritionEntry> entries;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ZenCard(
      radius: 20,
      backgroundColor: isDark ? const Color(0xFF1A2438) : AppColors.surface,
      borderColor: isDark ? const Color(0xFF2D3E61) : const Color(0xFFD8E2F8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saved history',
            style: AppTypography.titleLarge.copyWith(
              color: isDark ? AppColors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (entries.isEmpty)
            Text(
              'No meals logged yet.',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.textSecondary,
              ),
            )
          else
            Column(
              children: entries.take(20).map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(File(entry.imagePath)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.analysis.calories} kcal • ${entry.analysis.proteinG}p/${entry.analysis.carbsG}c/${entry.analysis.fatsG}f',
                              style: AppTypography.labelMedium.copyWith(
                                color: isDark
                                    ? AppColors.gray300
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(entry.createdAt),
                              style: AppTypography.caption.copyWith(
                                color: isDark
                                    ? AppColors.gray500
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime dateTime) {
    final mm = dateTime.month.toString().padLeft(2, '0');
    final dd = dateTime.day.toString().padLeft(2, '0');
    final hh = dateTime.hour.toString().padLeft(2, '0');
    final min = dateTime.minute.toString().padLeft(2, '0');
    return '$mm/$dd/${dateTime.year} $hh:$min';
  }
}
