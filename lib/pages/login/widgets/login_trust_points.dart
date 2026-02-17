import 'package:flutter/material.dart';
import 'package:p2f/theme/theme.dart';

/// Modern trust point chips with icons
class LoginTrustPoints extends StatelessWidget {
  const LoginTrustPoints({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _TrustChip(
          label: 'Local Storage',
          icon: Icons.storage_outlined,
          isDark: isDark,
        ),
        _TrustChip(
          label: 'Encrypted',
          icon: Icons.lock_outline,
          isDark: isDark,
        ),
        _TrustChip(
          label: 'Direct Verification',
          icon: Icons.verified_user_outlined,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({
    required this.label,
    required this.icon,
    required this.isDark,
  });

  final String label;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray800 : AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark ? AppColors.gray300 : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
