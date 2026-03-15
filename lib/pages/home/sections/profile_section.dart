import 'package:flutter/material.dart';
import 'package:p2f/models/user_profile.dart';
import 'package:p2f/pages/profile_edit_page.dart';
import 'package:p2f/theme/theme.dart';
import 'package:p2f/widgets/global/global_widgets.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({
    required this.profile,
    required this.onLogout,
    super.key,
  });

  final UserProfile? profile;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Hero ─────────────────────────────────────────────────────────────
        _ProfileHero(profile: profile),

        const SizedBox(height: 28),
        const Divider(height: 1, thickness: 1, color: AppColors.border),
        const SizedBox(height: 28),

        // ── Stats snapshot (only when profile exists) ─────────────────────
        if (profile != null) ...[
          _StatsSnapshot(profile: profile!),
          const SizedBox(height: 24),
        ],

        // ── Edit button ───────────────────────────────────────────────────
        _EditProfileButton(hasProfile: profile != null),

        const SizedBox(height: 32),
        const Divider(height: 1, thickness: 1, color: AppColors.border),
        const SizedBox(height: 28),

        // ── Account / danger zone ─────────────────────────────────────────
        _AccountBlock(onLogout: onLogout),

        const SizedBox(height: 40),
      ],
    );
  }
}

// ── Hero ──────────────────────────────────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final firstName = profile?.name.split(' ').first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROFILE',
          style: AppTypography.tag.copyWith(
            color: AppColors.subtle,
            letterSpacing: 2.5,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          firstName != null ? 'Hey,\n$firstName.' : 'Your\nprofile.',
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
                'Your details stay on this device — used by your AI coach to personalise guidance.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.subtle,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Stats snapshot ────────────────────────────────────────────────────────────

class _StatsSnapshot extends StatelessWidget {
  const _StatsSnapshot({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SNAPSHOT',
          style: AppTypography.tag.copyWith(
            color: AppColors.faint,
            letterSpacing: 2,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 18),

        // Avatar + name row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _InitialsAvatar(name: profile.name),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: AppTypography.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${profile.age} years old',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.subtle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Metrics row
        Row(
          children: [
            _StatPill(
              label: 'WEIGHT',
              value: '${profile.weightKg.toStringAsFixed(1)} kg',
            ),
            const SizedBox(width: 10),
            _StatPill(
              label: 'HEIGHT',
              value: '${profile.heightCm.toStringAsFixed(0)} cm',
            ),
            const SizedBox(width: 10),
            _StatPill(
              label: 'AGE',
              value: '${profile.age} yrs',
            ),
          ],
        ),

        if (profile.healthGoals.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'GOALS',
            style: AppTypography.tag.copyWith(
              color: AppColors.faint,
              letterSpacing: 2,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.healthGoals
                .map((goal) => ZenBadge(label: goal))
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.name});

  final String name;

  String _initials() {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceElevated,
        border: Border.all(color: AppColors.borderStrong, width: 1.5),
      ),
      child: Center(
        child: Text(
          _initials(),
          style: AppTypography.titleMedium.copyWith(
            fontSize: 20,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.faint,
                fontSize: 9,
                letterSpacing: 1.2,
                height: 1,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: AppTypography.titleSmall.copyWith(
                fontSize: 14,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Edit profile button ───────────────────────────────────────────────────────

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton({required this.hasProfile});

  final bool hasProfile;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const ProfileEditPage()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceElevated,
                border: Border.all(color: AppColors.borderStrong),
              ),
              child: const Icon(
                Icons.edit_rounded,
                size: 16,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasProfile ? 'Edit profile' : 'Set up profile',
                    style: AppTypography.labelLarge,
                  ),
                  Text(
                    hasProfile
                        ? 'Update your name, stats, and goals'
                        : 'Add your details for personalised coaching',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.subtle,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.subtle,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Account block ─────────────────────────────────────────────────────────────

class _AccountBlock extends StatelessWidget {
  const _AccountBlock({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACCOUNT',
          style: AppTypography.tag.copyWith(
            color: AppColors.faint,
            letterSpacing: 2,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 16),

        // Logout row
        GestureDetector(
          onTap: onLogout,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFF0D0000),
              border: Border.all(color: const Color(0x33FF4444)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1A0505),
                    border: Border.all(color: const Color(0x44FF4444)),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 16,
                    color: Color(0xFFFF4444),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Log out',
                        style: AppTypography.labelLarge.copyWith(
                          color: const Color(0xFFFF4444),
                        ),
                      ),
                      Text(
                        'Clears all data from this device',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.subtle,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Color(0x88FF4444),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Small privacy note
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 12,
                color: AppColors.faint,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'All data is stored locally on your device only. Nothing is shared with any server.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.faint,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
