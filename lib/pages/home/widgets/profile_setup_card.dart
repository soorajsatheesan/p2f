import 'dart:async';

import 'package:flutter/material.dart';
import 'package:p2f/models/user_profile.dart';
import 'package:p2f/pages/home/widgets/user_profile_form.dart';
import 'package:p2f/theme/theme.dart';
import 'package:p2f/widgets/global/global_widgets.dart';

class ProfileSetupCard extends StatefulWidget {
  const ProfileSetupCard({
    required this.profile,
    required this.isSaving,
    required this.onSave,
    required this.onOpenProfile,
    super.key,
  });

  final UserProfile? profile;
  final bool isSaving;
  final ValueChanged<UserProfile> onSave;
  final VoidCallback onOpenProfile;

  @override
  State<ProfileSetupCard> createState() => _ProfileSetupCardState();
}

class _ProfileSetupCardState extends State<ProfileSetupCard> {
  bool _collapsed = false;
  bool _hidden = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _collapsed = widget.profile != null;
    _hidden = widget.profile != null;
  }

  @override
  void didUpdateWidget(covariant ProfileSetupCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile == null && widget.profile != null) {
      setState(() {
        _collapsed = true;
        _hidden = false;
      });
      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(seconds: 5), () {
        if (!mounted) return;
        setState(() {
          _hidden = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hidden) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ZenCard(
      radius: 24,
      backgroundColor: isDark ? const Color(0xFF1A2438) : AppColors.surface,
      borderColor: isDark ? const Color(0xFF2D3E61) : const Color(0xFFD8E2F8),
      child: AnimatedSwitcher(
        duration: AppTheme.normalDuration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: (_collapsed && widget.profile != null)
            ? _CompletedState(
                key: const ValueKey('completed'),
                profile: widget.profile!,
              )
            : _FormState(
                key: const ValueKey('form'),
                profile: widget.profile,
                isSaving: widget.isSaving,
                onSave: widget.onSave,
              ),
      ),
    );
  }
}

class _CompletedState extends StatelessWidget {
  const _CompletedState({required super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF1F8A4C),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Profile setup completed',
              style: AppTypography.titleMedium.copyWith(
                color: isDark ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '${profile.name}, ${profile.age} yrs • ${profile.weightKg.toStringAsFixed(1)}kg • ${profile.heightCm.toStringAsFixed(1)}cm',
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.gray400 : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _FormState extends StatelessWidget {
  const _FormState({
    required super.key,
    required this.profile,
    required this.isSaving,
    required this.onSave,
  });

  final UserProfile? profile;
  final bool isSaving;
  final ValueChanged<UserProfile> onSave;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us about you',
          style: AppTypography.headlineSmall.copyWith(
            color: isDark ? AppColors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Used locally to personalize your fitness guidance.',
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.gray400 : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        UserProfileForm(
          initialProfile: profile,
          isSaving: isSaving,
          submitLabel: profile == null ? 'Save details' : 'Update details',
          onSubmit: onSave,
        ),
      ],
    );
  }
}
