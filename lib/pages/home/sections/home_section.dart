import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2f/models/user_profile.dart';
import 'package:p2f/pages/home/widgets/profile_setup_card.dart';
import 'package:p2f/providers/motivation_quote_provider.dart';
import 'package:p2f/theme/theme.dart';

class HomeSection extends ConsumerStatefulWidget {
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
  ConsumerState<HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends ConsumerState<HomeSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuoteIfPossible();
    });
  }

  @override
  void didUpdateWidget(covariant HomeSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldProfileSignature = _profileSignature(oldWidget.profile);
    final newProfileSignature = _profileSignature(widget.profile);
    if (oldProfileSignature != newProfileSignature) {
      _loadQuoteIfPossible(force: true);
    }
  }

  void _loadQuoteIfPossible({bool force = false}) {
    final profile = widget.profile;
    if (profile == null) return;
    ref
        .read(motivationQuoteProvider.notifier)
        .fetchForProfile(profile: profile, force: force);
  }

  String? _profileSignature(UserProfile? profile) {
    if (profile == null) return null;
    return '${profile.name}|${profile.age}|${profile.weightKg}|${profile.heightCm}|${profile.healthGoal}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quoteState = ref.watch(motivationQuoteProvider);

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
        _MotivationQuoteCard(
          profile: widget.profile,
          quote: quoteState.quote,
          isLoading: quoteState.isLoading,
          errorMessage: quoteState.errorMessage,
          onRefresh: widget.profile == null
              ? null
              : () => ref
                    .read(motivationQuoteProvider.notifier)
                    .fetchForProfile(profile: widget.profile!, force: true),
        ),
        const SizedBox(height: 16),
        ProfileSetupCard(
          profile: widget.profile,
          isSaving: widget.isSavingProfile,
          onSave: widget.onSaveProfile,
          onOpenProfile: widget.onOpenProfile,
        ),
      ],
    );
  }
}

class _MotivationQuoteCard extends StatelessWidget {
  const _MotivationQuoteCard({
    required this.profile,
    required this.quote,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
  });

  final UserProfile? profile;
  final String? quote;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? const Color(0xFF18253A) : const Color(0xFFFCFEFF),
        border: Border.all(
          color: isDark ? const Color(0xFF2D3E61) : const Color(0xFFD8E2F8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Daily Motivation',
                style: AppTypography.titleSmall.copyWith(
                  color: isDark ? AppColors.gray200 : AppColors.gray800,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onRefresh,
                tooltip: 'Refresh quote',
                icon: Icon(
                  Icons.refresh_rounded,
                  color: isDark ? const Color(0xFF9EBEFF) : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (profile == null)
            Text(
              'Complete your profile to get a personal quote.',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            )
          else if (isLoading && (quote == null || quote!.isEmpty))
            Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Text(
                  'Writing your quote...',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.gray700,
                  ),
                ),
              ],
            )
          else if (errorMessage != null && (quote == null || quote!.isEmpty))
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  errorMessage!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? const Color(0xFFFFA8A8) : AppColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onRefresh,
                  child: const Text('Try again'),
                ),
              ],
            )
          else
            Text(
              quote ?? '',
              softWrap: true,
              style: AppTypography.headlineSmall.copyWith(
                height: 1.35,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          if (isLoading && quote != null && quote!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isDark ? const Color(0xFF9EBEFF) : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Refreshing...',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
