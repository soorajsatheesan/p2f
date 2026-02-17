import 'package:flutter/material.dart';
import 'package:p2f/models/user_profile.dart';
import 'package:p2f/pages/home/widgets/user_profile_form.dart';
import 'package:p2f/theme/theme.dart';
import 'package:p2f/widgets/global/global_widgets.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({
    required this.profile,
    required this.isSaving,
    required this.onSave,
    super.key,
  });

  final UserProfile? profile;
  final bool isSaving;
  final ValueChanged<UserProfile> onSave;

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
          Text(
            'Profile',
            style: AppTypography.headlineSmall.copyWith(
              color: isDark ? AppColors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Edit your details anytime. Stored only on this device.',
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          UserProfileForm(
            initialProfile: profile,
            isSaving: isSaving,
            submitLabel: profile == null ? 'Save profile' : 'Update profile',
            onSubmit: onSave,
          ),
        ],
      ),
    );
  }
}
