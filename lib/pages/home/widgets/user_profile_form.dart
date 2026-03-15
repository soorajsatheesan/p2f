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
  static const int _minimumAge = 13;
  static const int _maximumAge = 120;
  static const double _minimumWeightKg = 30;
  static const double _maximumWeightKg = 300;
  static const List<String> _goalOptions = <String>[
    'Fat loss',
    'Muscle gain',
    'Strength',
    'Endurance',
    'Mobility',
    'Better sleep',
    'Recovery',
    'Healthy eating',
    'Consistency',
    'Energy',
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late DateTime? _dob;
  late Set<String> _selectedGoals;

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
    _dob = p?.dateOfBirth;
    _selectedGoals = {...?p?.healthGoals};
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
      _dob = p.dateOfBirth;
      _selectedGoals = {...p.healthGoals};
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final latestDate = DateTime(now.year - _minimumAge, now.month, now.day);
    final earliestDate = DateTime(now.year - _maximumAge, now.month, now.day);
    final initial = _dob ?? DateTime(now.year - 22, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(earliestDate)
          ? earliestDate
          : (initial.isAfter(latestDate) ? latestDate : initial),
      firstDate: earliestDate,
      lastDate: latestDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.foreground,
              onPrimary: AppColors.background,
              surface: AppColors.background,
              onSurface: AppColors.foreground,
            ),
          ),
          child: child!,
        );
      },
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
    final weight = double.tryParse(_weightController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final age = _dob == null ? null : _calculateAge(_dob!);

    setState(() {
      _nameError = name.isEmpty ? 'Enter your name' : null;
      _dobError = _dob == null
          ? 'Select date of birth'
          : (age! < _minimumAge || age > _maximumAge)
          ? 'Age must be between $_minimumAge and $_maximumAge'
          : null;
      _weightError = (weight == null)
          ? 'Enter a valid weight (kg)'
          : (weight < _minimumWeightKg || weight > _maximumWeightKg)
          ? 'Weight must be between ${_minimumWeightKg.toStringAsFixed(0)} and ${_maximumWeightKg.toStringAsFixed(0)} kg'
          : null;
      _heightError = (height == null || height <= 0)
          ? 'Enter a valid height (cm)'
          : null;
      _goalError = _selectedGoals.length < 3
          ? 'Select at least 3 health goals'
          : null;
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
        healthGoals: _goalOptions
            .where((goal) => _selectedGoals.contains(goal))
            .toList(),
      ),
    );
  }

  void _toggleGoal(String goal) {
    setState(() {
      if (_selectedGoals.contains(goal)) {
        _selectedGoals.remove(goal);
      } else {
        _selectedGoals.add(goal);
      }
      if (_goalError != null && _selectedGoals.length >= 3) {
        _goalError = null;
      }
    });
  }

  int _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    var years = now.year - dateOfBirth.year;
    final hadBirthday =
        now.month > dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day >= dateOfBirth.day);
    if (!hadBirthday) years -= 1;
    return years;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZenInputField(
          controller: _nameController,
          onChanged: (_) {
            if (_nameError != null) setState(() => _nameError = null);
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
          helperText: 'Age must be between $_minimumAge and $_maximumAge',
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ZenInputField(
                controller: _weightController,
                onChanged: (_) {
                  if (_weightError != null) setState(() => _weightError = null);
                },
                labelText: 'Weight (kg)',
                hintText: '72',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                enabled: !widget.isSaving,
                errorText: _weightError,
                helperText:
                    '${_minimumWeightKg.toStringAsFixed(0)}-${_maximumWeightKg.toStringAsFixed(0)} kg',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ZenInputField(
                controller: _heightController,
                onChanged: (_) {
                  if (_heightError != null) setState(() => _heightError = null);
                },
                labelText: 'Height (cm)',
                hintText: '176',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                enabled: !widget.isSaving,
                errorText: _heightError,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Health goals',
          style: AppTypography.labelLarge.copyWith(color: AppColors.foreground),
        ),
        const SizedBox(height: 6),
        Text(
          'Select at least 3',
          style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _goalOptions.map((goal) {
            final isSelected = _selectedGoals.contains(goal);
            return FilterChip(
              label: Text(goal),
              selected: isSelected,
              onSelected: widget.isSaving ? null : (_) => _toggleGoal(goal),
              showCheckmark: false,
              selectedColor: AppColors.foreground,
              backgroundColor: AppColors.surface,
              disabledColor: AppColors.surface,
              side: BorderSide(
                color: isSelected ? AppColors.foreground : AppColors.border,
              ),
              labelStyle: AppTypography.chip.copyWith(
                color: isSelected ? AppColors.background : AppColors.foreground,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }).toList(),
        ),
        if (_goalError != null) ...[
          const SizedBox(height: 8),
          Text(
            _goalError!,
            style: AppTypography.errorText,
          ),
        ],
        const SizedBox(height: 16),
        ZenPrimaryButton(
          label: widget.submitLabel,
          isLoading: widget.isSaving,
          onPressed: widget.isSaving ? null : _submit,
          icon: Icons.check_rounded,
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
    this.helperText,
  });

  final DateTime? dateOfBirth;
  final VoidCallback? onTap;
  final String? errorText;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final hasValue = dateOfBirth != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: errorText != null ? AppColors.error : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 18,
                  color: AppColors.subtle,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasValue
                        ? _formatDate(dateOfBirth!)
                        : 'Date of birth (used to calculate age)',
                    style: AppTypography.bodyMedium.copyWith(
                      color: hasValue ? AppColors.foreground : AppColors.faint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null || helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText ?? helperText!,
            style: errorText != null
                ? AppTypography.errorText
                : AppTypography.bodySmall.copyWith(color: AppColors.muted),
          ),
        ],
      ],
    );
  }

  static String _formatDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }
}
