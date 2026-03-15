import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2f/models/user_profile.dart';
import 'package:p2f/providers/user_profile_provider.dart';
import 'package:p2f/theme/theme.dart';
import 'package:p2f/widgets/global/animations.dart';
import 'package:p2f/widgets/global/zen_primary_button.dart';

class TellUsAboutYouPage extends ConsumerStatefulWidget {
  const TellUsAboutYouPage({super.key});

  @override
  ConsumerState<TellUsAboutYouPage> createState() =>
      _TellUsAboutYouPageState();
}

class _TellUsAboutYouPageState extends ConsumerState<TellUsAboutYouPage>
    with SingleTickerProviderStateMixin {
  // ── Constants ────────────────────────────────────────────────────────────────
  static const _goalOptions = [
    'Fat loss', 'Muscle gain', 'Strength', 'Endurance',
    'Mobility', 'Better sleep', 'Recovery', 'Healthy eating',
    'Consistency', 'Energy',
  ];
  static const int _minAge = 13;
  static const int _maxAge = 120;
  static const double _minWeight = 30;
  static const double _maxWeight = 300;

  // ── Form state ────────────────────────────────────────────────────────────────
  late final AnimationController _animCtrl;
  final _nameCtrl    = TextEditingController();
  final _weightCtrl  = TextEditingController();
  final _heightCtrl  = TextEditingController();
  DateTime? _dob;
  final Set<String> _goals = {};

  String? _nameErr;
  String? _dobErr;
  String? _weightErr;
  String? _heightErr;
  String? _goalErr;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(duration: AppTheme.slowDuration, vsync: this)
      ..forward();
    // Pre-fill if profile already exists (edit flow)
    final p = ref.read(userProfileProvider).profile;
    if (p != null) {
      _nameCtrl.text   = p.name;
      _weightCtrl.text = p.weightKg.toStringAsFixed(1);
      _heightCtrl.text = p.heightCm.toStringAsFixed(1);
      _dob             = p.dateOfBirth;
      _goals.addAll(p.healthGoals);
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────────
  bool _validate() {
    final name   = _nameCtrl.text.trim();
    final weight = double.tryParse(_weightCtrl.text.trim());
    final height = double.tryParse(_heightCtrl.text.trim());
    final age    = _dob == null ? null : _age(_dob!);

    setState(() {
      _nameErr = name.isEmpty ? 'Enter your name' : null;
      _dobErr  = _dob == null
          ? 'Select your date of birth'
          : (age! < _minAge || age > _maxAge)
              ? 'Age must be between $_minAge and $_maxAge'
              : null;
      _weightErr = weight == null
          ? 'Enter your weight'
          : (weight < _minWeight || weight > _maxWeight)
              ? '${_minWeight.toStringAsFixed(0)}–${_maxWeight.toStringAsFixed(0)} kg only'
              : null;
      _heightErr =
          (height == null || height <= 0) ? 'Enter your height' : null;
      _goalErr =
          _goals.length < 3 ? 'Pick at least 3 goals' : null;
    });

    return _nameErr == null &&
        _dobErr == null &&
        _weightErr == null &&
        _heightErr == null &&
        _goalErr == null;
  }

  int _age(DateTime dob) {
    final now = DateTime.now();
    var y = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) { y--; }
    return y;
  }

  // ── Submit ────────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (_isSubmitting || !_validate()) return;
    setState(() => _isSubmitting = true);

    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    await ref.read(userProfileProvider.notifier).saveProfile(
      UserProfile(
        name:        _nameCtrl.text.trim(),
        dateOfBirth: _dob!,
        weightKg:    double.parse(_weightCtrl.text.trim()),
        heightCm:    double.parse(_heightCtrl.text.trim()),
        healthGoals: _goalOptions
            .where((g) => _goals.contains(g))
            .toList(),
      ),
    );
    if (!mounted) return;

    final state = ref.read(userProfileProvider);
    if (state.profile == null || state.errorMessage != null) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        _errorSnackBar(state.errorMessage ?? 'Unable to save. Try again.'),
      );
    }
  }

  Future<void> _pickDob() async {
    final now     = DateTime.now();
    final latest   = DateTime(now.year - _minAge, now.month, now.day);
    final earliest = DateTime(now.year - _maxAge, now.month, now.day);
    final initial  = _dob ?? DateTime(now.year - 22, now.month, now.day);
    final clamped  = initial.isBefore(earliest)
        ? earliest
        : (initial.isAfter(latest) ? latest : initial);

    final picked = await showDatePicker(
      context: context,
      initialDate: clamped,
      firstDate: earliest,
      lastDate: latest,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.foreground,
            onPrimary: AppColors.background,
            surface: AppColors.background,
            onSurface: AppColors.foreground,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dob    = picked;
        _dobErr = null;
      });
    }
  }

  void _toggleGoal(String goal) {
    setState(() {
      if (_goals.contains(goal)) {
        _goals.remove(goal);
      } else {
        _goals.add(goal);
      }
      if (_goalErr != null && _goals.length >= 3) _goalErr = null;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final hPad = MediaQuery.of(context).size.width < 420 ? 20.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: AppTheme.normalDuration,
          switchInCurve: AppTheme.primaryEasing,
          switchOutCurve: Curves.easeInCubic,
          child: _isSubmitting
              ? const _CompletionView()
              : _buildForm(hPad),
        ),
      ),
    );
  }

  Widget _buildForm(double hPad) {
    return FadeSlideAnimation(
      key: const ValueKey('form'),
      animation: CurvedAnimation(
        parent: _animCtrl,
        curve: AppTheme.primaryEasing,
      ),
      slideBegin: const Offset(0, 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Headline ──────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 36, hPad, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tell us\nabout you.',
                  style: AppTypography.displaySmall.copyWith(
                    fontSize: 42,
                    height: 0.95,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Stays on your device. Used for personalized coaching.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.faint,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          // ── Form ──────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(hPad, 36, hPad, 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      _LineField(
                        label: 'Name',
                        controller: _nameCtrl,
                        hint: 'Jane Doe',
                        error: _nameErr,
                        enabled: !_isSubmitting,
                        onChanged: (_) {
                          if (_nameErr != null) {
                            setState(() => _nameErr = null);
                          }
                        },
                      ),
                      const SizedBox(height: 28),
                      // Date of birth
                      _LineDateField(
                        label: 'Date of birth',
                        value: _dob,
                        error: _dobErr,
                        onTap: _isSubmitting ? null : _pickDob,
                      ),
                      const SizedBox(height: 28),
                      // Weight + Height
                      Row(
                        children: [
                          Expanded(
                            child: _LineField(
                              label: 'Weight (kg)',
                              controller: _weightCtrl,
                              hint: '72',
                              error: _weightErr,
                              enabled: !_isSubmitting,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              onChanged: (_) {
                                if (_weightErr != null) {
                                  setState(() => _weightErr = null);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _LineField(
                              label: 'Height (cm)',
                              controller: _heightCtrl,
                              hint: '176',
                              error: _heightErr,
                              enabled: !_isSubmitting,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              onChanged: (_) {
                                if (_heightErr != null) {
                                  setState(() => _heightErr = null);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      // Goals header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            'Goals',
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.foreground,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'pick at least 3',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.faint,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Goal chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _goalOptions.map((goal) {
                          final selected = _goals.contains(goal);
                          return GestureDetector(
                            onTap: _isSubmitting
                                ? null
                                : () => _toggleGoal(goal),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              curve: AppTheme.primaryEasing,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.foreground
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.foreground
                                      : AppColors.border,
                                ),
                              ),
                              child: Text(
                                goal,
                                style: AppTypography.bodySmall.copyWith(
                                  color: selected
                                      ? AppColors.background
                                      : AppColors.muted,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (_goalErr != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 13,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 6),
                            Text(_goalErr!, style: AppTypography.errorText),
                          ],
                        ),
                      ],
                      const SizedBox(height: 40),
                      // Submit
                      ZenPrimaryButton(
                        label: 'Continue',
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting ? null : _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Line input field ──────────────────────────────────────────────────────────

class _LineField extends StatelessWidget {
  const _LineField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.hint,
    this.error,
    this.enabled = true,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hint;
  final String? error;
  final bool enabled;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      enabled: enabled,
      keyboardType: keyboardType,
      style: AppTypography.input,
      cursorColor: AppColors.foreground,
      cursorWidth: 1.5,
      cursorRadius: const Radius.circular(1),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.faint,
          letterSpacing: 0.5,
        ),
        floatingLabelStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.subtle,
          letterSpacing: 0.5,
          fontSize: 11,
        ),
        hintText: hint,
        hintStyle: AppTypography.inputHint,
        errorText: error,
        errorStyle: AppTypography.errorText,
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.foreground),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.error),
        ),
        disabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.divider),
        ),
        filled: false,
        contentPadding: const EdgeInsets.only(bottom: 10),
        isDense: true,
      ),
    );
  }
}

// ── Line date field ───────────────────────────────────────────────────────────

class _LineDateField extends StatelessWidget {
  const _LineDateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.error,
  });

  final String label;
  final DateTime? value;
  final VoidCallback? onTap;
  final String? error;

  static String _fmt(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    final lineColor = error != null ? AppColors.error : AppColors.border;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.faint,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  hasValue ? _fmt(value!) : 'YYYY-MM-DD',
                  style: AppTypography.input.copyWith(
                    color: hasValue
                        ? AppColors.foreground
                        : AppColors.faint,
                  ),
                ),
              ),
              Icon(
                Icons.unfold_more_rounded,
                size: 16,
                color: AppColors.faint,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: lineColor),
          if (error != null) ...[
            const SizedBox(height: 6),
            Text(error!, style: AppTypography.errorText),
          ],
        ],
      ),
    );
  }
}

// ── Snackbar helpers ──────────────────────────────────────────────────────────

SnackBar _errorSnackBar(String message) => SnackBar(
  content: Row(
    children: [
      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 16),
      const SizedBox(width: 10),
      Expanded(
        child: Text(message, style: const TextStyle(color: AppColors.foreground)),
      ),
    ],
  ),
  backgroundColor: const Color(0xFF1A0707),
  behavior: SnackBarBehavior.floating,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  duration: const Duration(seconds: 4),
);

// ── Completion view ───────────────────────────────────────────────────────────

class _CompletionView extends StatelessWidget {
  const _CompletionView();

  @override
  Widget build(BuildContext context) {
    return FadeSlideAnimation(
      key: const ValueKey('complete'),
      animation: const AlwaysStoppedAnimation<double>(1),
      slideBegin: const Offset(0, 0.02),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderStrong, width: 1.5),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.foreground,
                size: 22,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'All set.',
              style: AppTypography.displaySmall.copyWith(
                fontSize: 42,
                height: 0.95,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Taking you to your workspace…',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.subtle,
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.subtle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
