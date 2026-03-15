import 'package:flutter/material.dart';
import 'package:p2f/theme/theme.dart';
import 'package:p2f/widgets/global/monochrome_text.dart';

// ── ZenSectionHeader ─────────────────────────────────────────────────────────
//
// Reusable section header with eyebrow tag, title, optional description and
// optional trailing action widget. Use inside cards or as standalone headings.
//
// Usage:
//   ZenSectionHeader(
//     eyebrow: 'NUTRITION',
//     title: 'Today\'s intake',
//     description: 'Tap + to log a meal.',
//     trailing: IconButton(...),
//   )

class ZenSectionHeader extends StatelessWidget {
  const ZenSectionHeader({
    required this.title,
    super.key,
    this.eyebrow,
    this.description,
    this.trailing,
    this.titleStyle,
  });

  final String title;
  final String? eyebrow;
  final String? description;
  final Widget? trailing;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (eyebrow != null) ...[
                Text(eyebrow!, style: AppTypography.tag),
                const SizedBox(height: 6),
              ],
              Text(title, style: titleStyle ?? AppTypography.headlineSmall),
              if (description case final d?) ...[
                const SizedBox(height: 4),
                Text(d, style: AppTypography.bodySmall),
              ],
            ],
          ),
        ),
        if (trailing case final t?) t,
      ],
    );
  }
}

// ── ZenStatCard ───────────────────────────────────────────────────────────────
//
// Animated big-number stat display. Pass an integer `value` for an animated
// count-up. Useful for calorie totals, rep counts, etc.
//
// Usage:
//   ZenStatCard(
//     value: 1840,
//     unit: 'KCAL',
//     label: 'Total calories today',
//   )

class ZenStatCard extends StatelessWidget {
  const ZenStatCard({
    required this.value,
    required this.unit,
    required this.label,
    super.key,
    this.animationDuration = const Duration(milliseconds: 1400),
  });

  final int value;
  final String unit;
  final String label;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTypography.bodySmall),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnimatedStatNumber(
              value: value,
              style: AppTypography.statValue,
              duration: animationDuration,
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Text(unit, style: AppTypography.labelMedium),
            ),
          ],
        ),
      ],
    );
  }
}

// ── ZenEmptyState ─────────────────────────────────────────────────────────────
//
// Centered empty / placeholder state with icon, title, body copy, and an
// optional CTA button. Use inside cards when a list or section has no data.
//
// Usage:
//   ZenEmptyState(
//     icon: Icons.local_fire_department_rounded,
//     title: 'No meals yet',
//     body: 'Tap + to log your first meal.',
//   )

class ZenEmptyState extends StatelessWidget {
  const ZenEmptyState({
    required this.title,
    required this.body,
    super.key,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.symmetric(vertical: 28, horizontal: 8),
  });

  final String title;
  final String body;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 32, color: AppColors.faint),
              const SizedBox(height: 14),
            ],
            Text(
              title,
              style: AppTypography.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              body,
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.foreground,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
                child: Text(
                  actionLabel!.toUpperCase(),
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── ZenBadge ──────────────────────────────────────────────────────────────────
//
// Pill-shaped badge/chip. Replaces ad-hoc _MacroChip / trust chip patterns
// throughout the app. Supports an optional leading icon and custom text color.
//
// Usage:
//   ZenBadge(label: 'PROTEIN: 42 g')
//   ZenBadge(label: 'VERIFIED', icon: Icons.verified_user_outlined)

class ZenBadge extends StatelessWidget {
  const ZenBadge({
    required this.label,
    super.key,
    this.icon,
    this.textColor,
    this.compact = false,
  });

  final String label;
  final IconData? icon;
  final Color? textColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: compact ? 11 : 13,
              color: textColor ?? AppColors.subtle,
            ),
            SizedBox(width: compact ? 5 : 6),
          ],
          Text(
            label.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: textColor ?? AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

// ── ZenInfoRow ────────────────────────────────────────────────────────────────
//
// A horizontal label ↔ value pair with optional bottom divider. Stack these
// for detail/profile rows.
//
// Usage:
//   ZenInfoRow(label: 'Weight', value: '78.5 kg', divider: true)
//   ZenInfoRow(label: 'Goal', value: 'Lose fat')

class ZenInfoRow extends StatelessWidget {
  const ZenInfoRow({
    required this.label,
    required this.value,
    super.key,
    this.divider = false,
    this.labelColor,
  });

  final String label;
  final String value;
  final bool divider;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: labelColor ?? AppColors.subtle,
                ),
              ),
              const Spacer(),
              Text(value, style: AppTypography.labelLarge),
            ],
          ),
        ),
        if (divider)
          const Divider(height: 1, thickness: 1, color: AppColors.border),
      ],
    );
  }
}

// ── ZenDivider ────────────────────────────────────────────────────────────────
//
// Styled horizontal rule matching the design-theme border system.
// Optionally renders a centred label for section breaks.
//
// Usage:
//   ZenDivider()
//   ZenDivider(label: 'OR')

class ZenDivider extends StatelessWidget {
  const ZenDivider({super.key, this.label, this.padding});

  final String? label;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (label case null) {
      return Padding(
        padding: padding ?? EdgeInsets.zero,
        child: const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.border,
        ),
      );
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        children: [
          const Expanded(
            child: Divider(height: 1, thickness: 1, color: AppColors.border),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label!.toUpperCase(),
              style: AppTypography.labelSmall,
            ),
          ),
          const Expanded(
            child: Divider(height: 1, thickness: 1, color: AppColors.border),
          ),
        ],
      ),
    );
  }
}

// ── ZenPageHeader ─────────────────────────────────────────────────────────────
//
// Full-width top header for pages. Shows the P2F logo + page title on the
// left, and an optional greeting or trailing widget on the right.
//
// Usage (in home_page.dart _TopBar):
//   ZenPageHeader(title: 'WORKSPACE', greeting: 'Good morning')

class ZenPageHeader extends StatelessWidget {
  const ZenPageHeader({
    required this.title,
    super.key,
    this.trailing,
    this.showLogo = true,
  });

  final String title;
  final Widget? trailing;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (showLogo) ...[
            // Small inline logo mark
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/p2f-logo.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Text(
            title,
            style: AppTypography.labelLarge.copyWith(letterSpacing: 2),
          ),
          const Spacer(),
          if (trailing case final t?) t,
        ],
      ),
    );
  }
}

// ── ZenOutlineHeading ─────────────────────────────────────────────────────────
//
// Convenience widget — solid heading line + outline heading line stacked, used
// as a hero-style display in section intros.
//
// Usage:
//   ZenOutlineHeading(solidText: 'FITNESS', outlineText: 'STARTS LOCAL')

class ZenOutlineHeading extends StatelessWidget {
  const ZenOutlineHeading({
    required this.solidText,
    required this.outlineText,
    super.key,
    this.solidFontSize = 48,
    this.outlineFontSize = 36,
    this.textAlign = TextAlign.start,
  });

  final String solidText;
  final String outlineText;
  final double solidFontSize;
  final double outlineFontSize;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          solidText,
          textAlign: textAlign,
          style: AppTypography.hero.copyWith(
            fontSize: solidFontSize,
            height: 0.95,
          ),
        ),
        MonochromeOutlineText(
          text: outlineText,
          textAlign: textAlign,
          style: AppTypography.hero.copyWith(
            fontSize: outlineFontSize,
            height: 0.95,
          ),
        ),
      ],
    );
  }
}
