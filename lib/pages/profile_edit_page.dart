import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2f/pages/home/widgets/user_profile_form.dart';
import 'package:p2f/providers/user_profile_provider.dart';
import 'package:p2f/theme/theme.dart';

class ProfileEditPage extends ConsumerWidget {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileProvider);
    final isNew = profileState.profile == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back button ────────────────────────────────────────────────
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: AppColors.foreground,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Header ─────────────────────────────────────────────────────
              Text(
                isNew ? 'SETUP' : 'EDIT',
                style: AppTypography.tag.copyWith(
                  color: AppColors.subtle,
                  letterSpacing: 2.5,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isNew ? 'Tell us\nabout you.' : 'Update\nyour details.',
                style: AppTypography.displaySmall.copyWith(
                  fontSize: 44,
                  height: 0.96,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 3,
                    decoration: const BoxDecoration(
                      color: AppColors.faint,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isNew
                          ? 'Your details are stored only on this device and used to personalise your coaching.'
                          : 'Keep your stats current for more accurate coaching and calorie targets.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.subtle,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              const SizedBox(height: 28),

              // ── Form ───────────────────────────────────────────────────────
              UserProfileForm(
                initialProfile: profileState.profile,
                isSaving: profileState.isSaving,
                submitLabel: isNew ? 'Save profile' : 'Save changes',
                onSubmit: (profile) async {
                  await ref
                      .read(userProfileProvider.notifier)
                      .saveProfile(profile);
                  if (context.mounted) Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
