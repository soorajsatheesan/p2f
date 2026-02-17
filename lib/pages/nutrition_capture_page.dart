import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:p2f/models/nutrition_entry.dart';
import 'package:p2f/providers/nutrition_provider.dart';
import 'package:p2f/theme/theme.dart';
import 'package:p2f/widgets/global/global_widgets.dart';

class NutritionCapturePage extends ConsumerStatefulWidget {
  const NutritionCapturePage({super.key});

  @override
  ConsumerState<NutritionCapturePage> createState() =>
      _NutritionCapturePageState();
}

class _NutritionCapturePageState extends ConsumerState<NutritionCapturePage>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();

  late final AnimationController _scanController;
  String? _imagePath;
  String? _descriptionError;
  NutritionEntry? _resultEntry;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 1700),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
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
      _resultEntry = null;
    });
  }

  Future<void> _analyze() async {
    final description = _descriptionController.text.trim();
    setState(() {
      _descriptionError = description.isEmpty
          ? 'Add a short meal description'
          : null;
    });

    if (_imagePath == null || description.isEmpty) return;

    _scanController.repeat();
    final entry = await ref
        .read(nutritionProvider.notifier)
        .analyzeAndSave(imagePath: _imagePath!, description: description);
    _scanController.stop();

    if (!mounted) return;

    if (entry == null) {
      final error = ref.read(nutritionProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Unable to analyze meal.')),
      );
      return;
    }

    setState(() {
      _resultEntry = entry;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Add Meal',
                        style: AppTypography.headlineSmall.copyWith(
                          color: isDark
                              ? AppColors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_resultEntry == null)
                    _Composer(
                      imagePath: _imagePath,
                      isAnalyzing: state.isAnalyzing,
                      scanAnimation: _scanController,
                      descriptionController: _descriptionController,
                      descriptionError: _descriptionError,
                      onPickCamera: () => _pickImage(ImageSource.camera),
                      onPickGallery: () => _pickImage(ImageSource.gallery),
                      onAnalyze: _analyze,
                    )
                  else
                    _SuccessCard(
                      entry: _resultEntry!,
                      onDone: () => Navigator.of(context).pop(true),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.imagePath,
    required this.isAnalyzing,
    required this.scanAnimation,
    required this.descriptionController,
    required this.descriptionError,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.onAnalyze,
  });

  final String? imagePath;
  final bool isAnalyzing;
  final AnimationController scanAnimation;
  final TextEditingController descriptionController;
  final String? descriptionError;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ZenCard(
      radius: 24,
      backgroundColor: isDark ? const Color(0xFF1A2438) : AppColors.surface,
      borderColor: isDark ? const Color(0xFF2D3E61) : const Color(0xFFD8E2F8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ScanImagePreview(
            imagePath: imagePath,
            isAnalyzing: isAnalyzing,
            scanAnimation: scanAnimation,
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 560;
              if (stacked) {
                return Column(
                  children: [
                    ZenSecondaryButton(
                      label: 'Take photo',
                      icon: Icons.camera_alt_rounded,
                      onPressed: isAnalyzing ? null : onPickCamera,
                    ),
                    const SizedBox(height: 10),
                    ZenSecondaryButton(
                      label: 'Choose image',
                      icon: Icons.photo_library_rounded,
                      onPressed: isAnalyzing ? null : onPickGallery,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: ZenSecondaryButton(
                      label: 'Take photo',
                      icon: Icons.camera_alt_rounded,
                      onPressed: isAnalyzing ? null : onPickCamera,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ZenSecondaryButton(
                      label: 'Choose image',
                      icon: Icons.photo_library_rounded,
                      onPressed: isAnalyzing ? null : onPickGallery,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          ZenInputField(
            controller: descriptionController,
            onChanged: (_) {},
            labelText: 'Meal description',
            hintText: 'e.g. chicken bowl with rice and avocado',
            maxLines: 3,
            errorText: descriptionError,
            enabled: !isAnalyzing,
          ),
          const SizedBox(height: 12),
          ZenPrimaryButton(
            label: isAnalyzing ? 'Analyzing...' : 'Analyze & save',
            isLoading: isAnalyzing,
            onPressed: isAnalyzing ? null : onAnalyze,
            icon: Icons.auto_awesome_rounded,
            backgroundColor: isDark
                ? const Color(0xFF9EBEFF)
                : AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _ScanImagePreview extends StatelessWidget {
  const _ScanImagePreview({
    required this.imagePath,
    required this.isAnalyzing,
    required this.scanAnimation,
  });

  final String? imagePath;
  final bool isAnalyzing;
  final AnimationController scanAnimation;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 250,
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
                'Select a meal image',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.gray500 : AppColors.textMuted,
                ),
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.file(File(imagePath!), fit: BoxFit.cover),
                  ),
                  if (isAnalyzing)
                    AnimatedBuilder(
                      animation: scanAnimation,
                      builder: (context, child) {
                        final value = scanAnimation.value;
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: _FuturisticScanOverlay(progress: value),
                            ),
                            const Positioned(
                              right: 10,
                              bottom: 10,
                              child: _ScanTag(),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}

class _FuturisticScanOverlay extends StatelessWidget {
  const _FuturisticScanOverlay({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final scanY = 220 * progress;

    return Stack(
      children: [
        Positioned.fill(child: Container(color: const Color(0x3A0C1220))),
        Positioned.fill(
          child: CustomPaint(painter: _HudGridPainter(progress: progress)),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: scanY,
          child: Container(
            height: 44,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0x003A74E0),
                  Color(0xAA3A74E0),
                  Color(0x88E88AB7),
                  Color(0x003A74E0),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: Transform.rotate(
            angle: progress * math.pi * 2,
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xAA8DB4FF), width: 1.2),
              ),
              child: Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0x88E88AB7),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Positioned(top: 10, left: 10, child: _CornerBracket()),
        const Positioned(
          top: 10,
          right: 10,
          child: _CornerBracket(isRight: true),
        ),
        const Positioned(
          bottom: 10,
          left: 10,
          child: _CornerBracket(isBottom: true),
        ),
        const Positioned(
          bottom: 10,
          right: 10,
          child: _CornerBracket(isRight: true, isBottom: true),
        ),
      ],
    );
  }
}

class _CornerBracket extends StatelessWidget {
  const _CornerBracket({this.isRight = false, this.isBottom = false});

  final bool isRight;
  final bool isBottom;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: (isRight ? math.pi / 2 : 0) + (isBottom ? math.pi : 0),
      child: SizedBox(
        width: 18,
        height: 18,
        child: CustomPaint(painter: _CornerBracketPainter()),
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const color = Color(0xCC8DB4FF);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width, 2)
      ..lineTo(2, 2)
      ..lineTo(2, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HudGridPainter extends CustomPainter {
  const _HudGridPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0x298DB4FF)
      ..strokeWidth = 0.7;
    final step = 22.0;
    final offset = progress * step;

    for (double x = -step + offset; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = -step + offset; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HudGridPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ScanTag extends StatelessWidget {
  const _ScanTag();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCC101726),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          'Scanning meal...',
          style: AppTypography.labelSmall.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({required this.entry, required this.onDone});

  final NutritionEntry entry;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ZenCard(
      radius: 24,
      backgroundColor: isDark ? const Color(0xFF1A2438) : AppColors.surface,
      borderColor: isDark ? const Color(0xFF2D3E61) : const Color(0xFFD8E2F8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF1F8A4C),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Saved successfully',
                style: AppTypography.titleLarge.copyWith(
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.analysis.mealName,
            style: AppTypography.headlineSmall.copyWith(
              color: isDark ? AppColors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Metric(
                label: 'Calories',
                value: '${entry.analysis.calories} kcal',
              ),
              _Metric(label: 'Protein', value: '${entry.analysis.proteinG} g'),
              _Metric(label: 'Carbs', value: '${entry.analysis.carbsG} g'),
              _Metric(label: 'Fats', value: '${entry.analysis.fatsG} g'),
              _Metric(label: 'Fiber', value: '${entry.analysis.fiberG} g'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.analysis.summary,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          ZenPrimaryButton(
            label: 'Done',
            onPressed: onDone,
            icon: Icons.check_rounded,
            backgroundColor: isDark
                ? const Color(0xFF9EBEFF)
                : AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

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
