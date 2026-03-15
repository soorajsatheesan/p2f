import 'package:flutter/material.dart';
import 'package:p2f/theme/theme.dart';

class LoginTermsTile extends StatelessWidget {
  const LoginTermsTile({
    required this.value,
    required this.onChanged,
    required this.showError,
    required this.onTermsTap,
    required this.onPrivacyTap,
    super.key,
    this.enabled = true,
    this.compact = false,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool showError;
  final bool enabled;
  final bool compact;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: compact,
          value: value,
          onChanged: enabled ? onChanged : null,
          controlAffinity: ListTileControlAffinity.leading,
          visualDensity: compact
              ? const VisualDensity(horizontal: -4, vertical: -4)
              : VisualDensity.standard,
          materialTapTargetSize: compact
              ? MaterialTapTargetSize.shrinkWrap
              : MaterialTapTargetSize.padded,
          activeColor: AppColors.foreground,
          checkColor: AppColors.background,
          checkboxShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          side: BorderSide(
            color: showError ? AppColors.error : AppColors.borderStrong,
            width: 2,
          ),
          title: Text.rich(
            TextSpan(
              style:
                  (compact ? AppTypography.bodySmall : AppTypography.bodyMedium)
                      .copyWith(color: AppColors.muted),
              children: [
                const TextSpan(text: 'I agree to the '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: InkWell(
                    onTap: onTermsTap,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          color: AppColors.foreground,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.foreground,
                          decorationThickness: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: ' and '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: InkWell(
                    onTap: onPrivacyTap,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: AppColors.foreground,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.foreground,
                          decorationThickness: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showError)
          AnimatedContainer(
            duration: AppTheme.fastDuration,
            padding: EdgeInsets.only(left: compact ? 8 : 12, top: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 14,
                  color: AppColors.error,
                ),
                const SizedBox(width: 6),
                Text(
                  'You must accept the terms to continue.',
                  style: AppTypography.errorText,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
