import 'package:flutter/material.dart';
import 'package:p2f/theme/theme.dart';

class ComingSoonPanel extends StatelessWidget {
  const ComingSoonPanel({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.headlineSmall),
          const SizedBox(height: 8),
          Text('Coming soon', style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}
