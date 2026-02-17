import 'package:flutter/material.dart';
import 'package:p2f/models/user_profile.dart';
import 'package:p2f/theme/theme.dart';
import 'package:p2f/widgets/global/global_widgets.dart';

class UserProfileForm extends StatefulWidget {
  const UserProfileForm({
    required this.onSubmit,
    required this.isSaving,
    super.key,
    this.initialProfile,
    this.submitLabel = 'Save details',
  });

  final UserProfile? initialProfile;
  final bool isSaving;
  final ValueChanged<UserProfile> onSubmit;
  final String submitLabel;

  @override
  State<UserProfileForm> createState() => _UserProfileFormState();
}

class _UserProfileFormState extends State<UserProfileForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _goalController;
  late DateTime? _dob;

  String? _nameError;
  String? _dobError;
  String? _weightError;
  String? _heightError;
  String? _goalError;

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile;
    _nameController = TextEditingController(text: p?.name ?? '');
    _weightController = TextEditingController(
      text: p == null ? '' : p.weightKg.toStringAsFixed(1),
    );
    _heightController = TextEditingController(
      text: p == null ? '' : p.heightCm.toStringAsFixed(1),
    );
    _goalController = TextEditingController(text: p?.healthGoal ?? '');
    _dob = p?.dateOfBirth;
  }

  @override
  void didUpdateWidget(covariant UserProfileForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialProfile != widget.initialProfile &&
        widget.initialProfile != null) {
      final p = widget.initialProfile!;
      _nameController.text = p.name;
      _weightController.text = p.weightKg.toStringAsFixed(1);
      _heightController.text = p.heightCm.toStringAsFixed(1);
      _goalController.text = p.healthGoal;
      _dob = p.dateOfBirth;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _dob ?? DateTime(now.year - 22, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: now,
    );

    if (selected != null) {
      setState(() {
        _dob = selected;
        _dobError = null;
      });
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    final goal = _goalController.text.trim();
    final weight = double.tryParse(_weightController.text.trim());
    final height = double.tryParse(_heightController.text.trim());

    setState(() {
      _nameError = name.isEmpty ? 'Enter your name' : null;
      _dobError = _dob == null ? 'Select date of birth' : null;
      _weightError = (weight == null || weight <= 0)
          ? 'Enter a valid weight (kg)'
          : null;
      _heightError = (height == null || height <= 0)
          ? 'Enter a valid height (cm)'
          : null;
      _goalError = goal.isEmpty ? 'Enter your health goal' : null;
    });

    if (_nameError != null ||
        _dobError != null ||
        _weightError != null ||
        _heightError != null ||
        _goalError != null) {
      return;
    }

    widget.onSubmit(
      UserProfile(
        name: name,
        dateOfBirth: _dob!,
        weightKg: weight!,
        heightCm: height!,
        healthGoal: goal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZenInputField(
          controller: _nameController,
          onChanged: (_) {
            if (_nameError != null) {
              setState(() {
                _nameError = null;
              });
            }
          },
          labelText: 'Name',
          hintText: 'Jane Doe',
          enabled: !widget.isSaving,
          errorText: _nameError,
        ),
        const SizedBox(height: 10),
        _DobField(
          dateOfBirth: _dob,
          onTap: widget.isSaving ? null : _pickDob,
          errorText: _dobError,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ZenInputField(
                controller: _weightController,
                onChanged: (_) {
                  if (_weightError != null) {
                    setState(() {
                      _weightError = null;
                    });
                  }
                },
                labelText: 'Weight (kg)',
                hintText: '72',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                enabled: !widget.isSaving,
                errorText: _weightError,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ZenInputField(
                controller: _heightController,
                onChanged: (_) {
                  if (_heightError != null) {
                    setState(() {
                      _heightError = null;
                    });
                  }
                },
                labelText: 'Height (cm)',
                hintText: '176',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                enabled: !widget.isSaving,
                errorText: _heightError,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ZenInputField(
          controller: _goalController,
          onChanged: (_) {
            if (_goalError != null) {
              setState(() {
                _goalError = null;
              });
            }
          },
          labelText: 'Health goal',
          hintText: 'Fat loss, strength, endurance, etc.',
          enabled: !widget.isSaving,
          errorText: _goalError,
        ),
        const SizedBox(height: 14),
        ZenPrimaryButton(
          label: widget.submitLabel,
          isLoading: widget.isSaving,
          onPressed: widget.isSaving ? null : _submit,
          icon: Icons.check_rounded,
          backgroundColor: isDark ? const Color(0xFF9EBEFF) : AppColors.primary,
          foregroundColor: Colors.white,
        ),
      ],
    );
  }
}

class _DobField extends StatelessWidget {
  const _DobField({
    required this.dateOfBirth,
    required this.onTap,
    this.errorText,
  });

  final DateTime? dateOfBirth;
  final VoidCallback? onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasValue = dateOfBirth != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.gray800 : AppColors.gray50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: errorText != null
                ? AppColors.error
                : (isDark ? AppColors.borderDark : AppColors.border),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 18,
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasValue
                    ? _formatDate(dateOfBirth!)
                    : 'Date of birth (used to calculate age)',
                style: AppTypography.bodyMedium.copyWith(
                  color: hasValue
                      ? (isDark ? AppColors.white : AppColors.textPrimary)
                      : (isDark ? AppColors.gray500 : AppColors.textMuted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }
}
