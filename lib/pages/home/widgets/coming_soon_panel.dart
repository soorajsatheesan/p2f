import 'package:flutter/material.dart';
import 'package:p2f/theme/theme.dart';

class ComingSoonPanel extends StatelessWidget {
  const ComingSoonPanel({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
            title,
            style: AppTypography.headlineSmall.copyWith(
              color: isDark ? AppColors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
