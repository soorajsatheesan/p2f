import 'package:flutter/material.dart';
import 'package:p2f/theme/theme.dart';

/// Modern terms acceptance tile with checkbox
class LoginTermsTile extends StatelessWidget {
  const LoginTermsTile({
    required this.value,
    required this.onChanged,
    required this.showError,
    required this.onTermsTap,
    required this.onPrivacyTap,
    super.key,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool showError;
  final bool enabled;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: value,
          onChanged: enabled ? onChanged : null,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: isDark
              ? const Color(0xFF9EBEFF)
              : const Color(0xFF2E63D3),
          checkColor: Colors.white,
          checkboxShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          side: BorderSide(
            color: showError
                ? (isDark ? AppColors.errorLight : AppColors.error)
                : (isDark ? AppColors.gray500 : AppColors.gray400),
            width: 2,
          ),
          title: Text.rich(
            TextSpan(
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.textSecondary,
              ),
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
                          color: isDark
                              ? AppColors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationThickness: 1.3,
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
                          color: isDark
                              ? AppColors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationThickness: 1.3,
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
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 14,
                  color: isDark ? AppColors.errorLight : AppColors.error,
                ),
                const SizedBox(width: 6),
                Text(
                  'You must accept the terms to continue.',
                  style: AppTypography.errorText.copyWith(
                    color: isDark ? AppColors.errorLight : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
