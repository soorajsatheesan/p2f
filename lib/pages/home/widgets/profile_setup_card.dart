import 'dart:async';

import 'package:flutter/material.dart';
import 'package:p2f/models/user_profile.dart';
import 'package:p2f/pages/home/widgets/user_profile_form.dart';
import 'package:p2f/theme/theme.dart';

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
        setState(() => _hidden = true);
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
    if (_hidden) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: AppTheme.normalDuration,
      switchInCurve: AppTheme.primaryEasing,
      switchOutCurve: Curves.easeInCubic,
      child: (_collapsed && widget.profile != null)
          ? _CompletedSection(
              key: const ValueKey('completed'),
              profile: widget.profile!,
            )
          : _FormSection(
              key: const ValueKey('form'),
              profile: widget.profile,
              isSaving: widget.isSaving,
              onSave: widget.onSave,
            ),
    );
  }
}

// ── Completed state ───────────────────────────────────────────────────────────

class _CompletedSection extends StatelessWidget {
  const _CompletedSection({required super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'PROFILE',
              style: AppTypography.tag.copyWith(
                color: AppColors.faint,
                letterSpacing: 2,
                fontSize: 10,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.check_circle_rounded,
              size: 11,
              color: AppColors.subtle,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          profile.name,
          style: AppTypography.headlineSmall.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${profile.age} yrs  ·  ${profile.weightKg.toStringAsFixed(1)} kg  ·  '
          '${profile.heightCm.toStringAsFixed(0)} cm',
          style: AppTypography.bodySmall.copyWith(color: AppColors.subtle),
        ),
        const SizedBox(height: 4),
        Text(
          profile.healthGoal,
          style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}

// ── Form state ────────────────────────────────────────────────────────────────

class _FormSection extends StatelessWidget {
  const _FormSection({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROFILE SETUP',
          style: AppTypography.tag.copyWith(
            color: AppColors.faint,
            letterSpacing: 2,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 14),
        Text('Tell us about you', style: AppTypography.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Used locally to personalize your fitness guidance.',
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: 22),
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
