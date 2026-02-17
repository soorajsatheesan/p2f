import 'package:flutter/material.dart';
import 'package:p2f/models/user_profile.dart';
import 'package:p2f/pages/home/widgets/profile_setup_card.dart';
import 'package:p2f/theme/theme.dart';

class HomeSection extends StatelessWidget {
  const HomeSection({
    required this.profile,
    required this.isSavingProfile,
    required this.onSaveProfile,
    required this.onOpenProfile,
    super.key,
  });

  final UserProfile? profile;
  final bool isSavingProfile;
  final ValueChanged<UserProfile> onSaveProfile;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF1A2235), Color(0xFF171D2E)]
                  : const [Color(0xFFF3F7FF), Color(0xFFF7ECF4)],
            ),
            border: Border.all(
              color: isDark ? const Color(0xFF2D3E61) : const Color(0xFFD8E2F8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to P2F',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.gray300 : AppColors.gray700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Build your local AI fitness workspace.',
                style: AppTypography.displaySmall.copyWith(
                  fontSize: 34,
                  height: 1.06,
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ProfileSetupCard(
          profile: profile,
          isSaving: isSavingProfile,
          onSave: onSaveProfile,
          onOpenProfile: onOpenProfile,
        ),
      ],
    );
  }
}
