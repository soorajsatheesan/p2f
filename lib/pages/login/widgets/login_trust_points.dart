import 'package:flutter/material.dart';
import 'package:p2f/theme/theme.dart';

class LoginTrustPoints extends StatelessWidget {
  const LoginTrustPoints({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: compact ? 8 : 10,
      runSpacing: compact ? 8 : 10,
      children: [
        _TrustChip(
          label: 'LOCAL STORAGE',
          icon: Icons.storage_outlined,
          compact: compact,
        ),
        _TrustChip(
          label: 'ENCRYPTED',
          icon: Icons.lock_outline,
          compact: compact,
        ),
        _TrustChip(
          label: 'DIRECT VERIFICATION',
          icon: Icons.verified_user_outlined,
          compact: compact,
        ),
      ],
    );
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({
    required this.label,
    required this.icon,
    required this.compact,
  });

  final String label;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 14,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: AppColors.subtle),
          SizedBox(width: compact ? 6 : 8),
          Text(label, style: AppTypography.labelSmall),
        ],
      ),
    );
  }
}
