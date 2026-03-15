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
      duration: const Duration(milliseconds: 2000),
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
      imageQuality: 88,
      maxWidth: 1400,
    );
    if (picked == null) return;
    setState(() {
      _imagePath = picked.path;
      _resultEntry = null;
    });
  }

  Future<void> _showPickerSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ImageSourceSheet(
        onCamera: () {
          Navigator.of(context).pop();
          _pickImage(ImageSource.camera);
        },
        onGallery: () {
          Navigator.of(context).pop();
          _pickImage(ImageSource.gallery);
        },
      ),
    );
  }

  Future<void> _analyze() async {
    final description = _descriptionController.text.trim();
    setState(() {
      _descriptionError =
          description.isEmpty ? 'Describe what you ate' : null;
    });
    if (_imagePath == null || description.isEmpty) return;

    _scanController.repeat();
    final entry = await ref
        .read(nutritionProvider.notifier)
        .analyzeAndSave(imagePath: _imagePath!, description: description);
    _scanController.stop();
    _scanController.reset();

    if (!mounted) return;

    if (entry == null) {
      final error = ref.read(nutritionProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        _errorSnackBar(error ?? 'Unable to analyze this meal.'),
      );
      return;
    }

    setState(() => _resultEntry = entry);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Back + title ──────────────────────────────────────────────
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderStrong),
                          color: AppColors.surface,
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.foreground,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NUTRITION',
                          style: AppTypography.tag.copyWith(
                            color: AppColors.faint,
                            letterSpacing: 2,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          'Log a meal',
                          style: AppTypography.headlineSmall,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                if (_resultEntry == null)
                  _Composer(
                    imagePath: _imagePath,
                    isAnalyzing: state.isAnalyzing,
                    scanAnimation: _scanController,
                    descriptionController: _descriptionController,
                    descriptionError: _descriptionError,
                    onPickImage: _showPickerSheet,
                    onAnalyze: _analyze,
                  )
                else
                  _SuccessCard(
                    entry: _resultEntry!,
                    onDone: () => Navigator.of(context).pop(true),
                    onAddAnother: () => setState(() {
                      _resultEntry = null;
                      _imagePath = null;
                      _descriptionController.clear();
                    }),
                  ),
              ],
            ),
          ),
        ),
    );
  }
}

// ── Composer ──────────────────────────────────────────────────────────────────

class _Composer extends StatelessWidget {
  const _Composer({
    required this.imagePath,
    required this.isAnalyzing,
    required this.scanAnimation,
    required this.descriptionController,
    required this.descriptionError,
    required this.onPickImage,
    required this.onAnalyze,
  });

  final String? imagePath;
  final bool isAnalyzing;
  final AnimationController scanAnimation;
  final TextEditingController descriptionController;
  final String? descriptionError;
  final VoidCallback onPickImage;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Image tap area ────────────────────────────────────────────────────
        _ImageArea(
          imagePath: imagePath,
          isAnalyzing: isAnalyzing,
          scanAnimation: scanAnimation,
          onTap: isAnalyzing ? null : onPickImage,
        ),

        const SizedBox(height: 20),

        // ── Description field ─────────────────────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WHAT IS THIS MEAL?',
              style: AppTypography.tag.copyWith(
                color: AppColors.faint,
                letterSpacing: 2,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              minLines: 2,
              maxLines: 4,
              enabled: !isAnalyzing,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.foreground,
              ),
              cursorColor: AppColors.foreground,
              cursorWidth: 1.5,
              decoration: InputDecoration(
                hintText:
                    'e.g. grilled chicken breast, brown rice, steamed broccoli',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.faint,
                ),
                errorText: descriptionError,
                errorStyle: AppTypography.bodySmall.copyWith(
                  color: AppColors.error,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.borderStrong),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── Analyze button ────────────────────────────────────────────────────
        ZenPrimaryButton(
          label: isAnalyzing ? 'Analyzing…' : 'Analyze & save',
          isLoading: isAnalyzing,
          onPressed: isAnalyzing ? null : onAnalyze,
          icon: Icons.auto_awesome_rounded,
        ),

        if (imagePath == null) ...[
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Add a photo first',
              style: AppTypography.bodySmall.copyWith(color: AppColors.faint),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Image area ────────────────────────────────────────────────────────────────

class _ImageArea extends StatelessWidget {
  const _ImageArea({
    required this.imagePath,
    required this.isAnalyzing,
    required this.scanAnimation,
    required this.onTap,
  });

  final String? imagePath;
  final bool isAnalyzing;
  final AnimationController scanAnimation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 280,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.surface,
          border: Border.all(
            color: imagePath != null
                ? AppColors.borderStrong
                : AppColors.border,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: imagePath == null
              ? _EmptyImagePlaceholder()
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(imagePath!), fit: BoxFit.cover),
                    if (isAnalyzing)
                      AnimatedBuilder(
                        animation: scanAnimation,
                        builder: (_, _) => _ScanOverlay(
                          progress: scanAnimation.value,
                        ),
                      )
                    else
                      _RetakeBadge(),
                  ],
                ),
        ),
      ),
    );
  }
}

class _EmptyImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderStrong),
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            color: AppColors.subtle,
            size: 22,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Tap to photograph your meal',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.subtle,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Camera or gallery',
          style: AppTypography.bodySmall,
        ),
      ],
    );
  }
}

class _RetakeBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.overlayHeavy,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.borderStrong),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.refresh_rounded,
                size: 12,
                color: AppColors.foreground,
              ),
              const SizedBox(width: 5),
              Text(
                'RETAKE',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.foreground,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Scan overlay ──────────────────────────────────────────────────────────────

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay({required this.progress});

  final double progress;

  static const double _height = 280.0;

  @override
  Widget build(BuildContext context) {
    // Beam sweeps 0→height and back (using sine for smooth oscillation)
    final beamY = (_height * 0.5) +
        (_height * 0.42) * math.sin(progress * math.pi * 2);

    return Stack(
      children: [
        // Subtle dark vignette
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Color(0x00000000),
                  Color(0x33000000),
                ],
              ),
            ),
          ),
        ),

        // Scan beam
        Positioned(
          left: 0,
          right: 0,
          top: beamY - 50,
          child: Container(
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00FFFFFF),
                  Color(0x08FFFFFF),
                  Color(0x22FFFFFF),
                  Color(0x08FFFFFF),
                  Color(0x00FFFFFF),
                ],
                stops: [0.0, 0.3, 0.5, 0.7, 1.0],
              ),
            ),
          ),
        ),

        // Corner brackets
        const Positioned(
          top: 16,
          left: 16,
          child: _CornerBracket(),
        ),
        const Positioned(
          top: 16,
          right: 16,
          child: _CornerBracket(isRight: true),
        ),
        const Positioned(
          bottom: 16,
          left: 16,
          child: _CornerBracket(isBottom: true),
        ),
        const Positioned(
          bottom: 16,
          right: 16,
          child: _CornerBracket(isRight: true, isBottom: true),
        ),

        // Status label
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppColors.overlayHeavy,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.borderStrong),
              ),
              child: Text(
                'READING MEAL…',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.foreground,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
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
        width: 20,
        height: 20,
        child: CustomPaint(painter: _CornerBracketPainter()),
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.foreground
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(size.width, 2)
        ..lineTo(2, 2)
        ..lineTo(2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Image source sheet ────────────────────────────────────────────────────────

class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet({required this.onCamera, required this.onGallery});

  final VoidCallback onCamera;
  final VoidCallback onGallery;

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
              Text('Add meal photo', style: AppTypography.headlineSmall),
              const SizedBox(height: 4),
              Text(
                "Choose how you'd like to capture this meal.",
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 20),
              _SourceOption(
                icon: Icons.camera_alt_rounded,
                title: 'Take a photo',
                subtitle: 'Capture with your camera right now',
                onTap: onCamera,
              ),
              const SizedBox(height: 10),
              _SourceOption(
                icon: Icons.photo_library_rounded,
                title: 'Choose from gallery',
                subtitle: 'Pick an existing photo from your library',
                onTap: onGallery,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderStrong),
              ),
              child: Icon(icon, size: 18, color: AppColors.foreground),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelLarge),
                Text(subtitle, style: AppTypography.bodySmall),
              ],
            ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Success card ──────────────────────────────────────────────────────────────

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({
    required this.entry,
    required this.onDone,
    required this.onAddAnother,
  });

  final NutritionEntry entry;
  final VoidCallback onDone;
  final VoidCallback onAddAnother;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Meal image preview
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            image: DecorationImage(
              image: FileImage(File(entry.imagePath)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.foreground,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Saved to your log',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.subtle,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Text(entry.analysis.mealName, style: AppTypography.headlineSmall),
        const SizedBox(height: 14),

        // Macro grid
        Row(
          children: [
            _ResultMacro(
              label: 'Calories',
              value: '${entry.analysis.calories}',
              unit: 'kcal',
            ),
            const SizedBox(width: 10),
            _ResultMacro(
              label: 'Protein',
              value: entry.analysis.proteinG.toStringAsFixed(1),
              unit: 'g',
            ),
            const SizedBox(width: 10),
            _ResultMacro(
              label: 'Carbs',
              value: entry.analysis.carbsG.toStringAsFixed(1),
              unit: 'g',
            ),
            const SizedBox(width: 10),
            _ResultMacro(
              label: 'Fats',
              value: entry.analysis.fatsG.toStringAsFixed(1),
              unit: 'g',
            ),
          ],
        ),

        const SizedBox(height: 14),
        Text(entry.analysis.summary, style: AppTypography.bodySmall),
        const SizedBox(height: 24),

        ZenPrimaryButton(
          label: 'Done',
          onPressed: onDone,
          icon: Icons.check_rounded,
        ),
        const SizedBox(height: 10),
        ZenSecondaryButton(
          label: 'Log another meal',
          onPressed: onAddAnother,
          icon: Icons.add_rounded,
          height: 48,
        ),
      ],
    );
  }
}

class _ResultMacro extends StatelessWidget {
  const _ResultMacro({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.titleSmall.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(
              '$label ($unit)',
              style: AppTypography.labelSmall.copyWith(
                fontSize: 9,
                color: AppColors.faint,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Snackbar helper ───────────────────────────────────────────────────────────

SnackBar _errorSnackBar(String message) => SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.foreground),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1A0707),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      duration: const Duration(seconds: 5),
    );
