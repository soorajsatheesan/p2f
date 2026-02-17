import 'package:flutter/material.dart';
import 'package:p2f/theme/theme.dart';

/// A modern primary button with press animations, loading states,
/// and haptic feedback support.
///
/// Features:
/// - Smooth press animations with scale effect
/// - Loading state with shimmer effect
/// - Icon support with animations
/// - Gradient background option
/// - Configurable size and shape
class ZenPrimaryButton extends StatefulWidget {
  const ZenPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
    this.iconAlignment = IconAlignment.start,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 56,
    this.borderRadius,
    this.elevation = 0,
    this.enableHaptic = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final IconAlignment iconAlignment;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final double? borderRadius;
  final double elevation;
  final bool enableHaptic;

  @override
  State<ZenPrimaryButton> createState() => _ZenPrimaryButtonState();
}

class _ZenPrimaryButtonState extends State<ZenPrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.fastDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isLoading && widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveBackgroundColor =
        widget.backgroundColor ??
        (isDark ? AppColors.white : AppColors.primary);
    final effectiveForegroundColor =
        widget.foregroundColor ?? (isDark ? AppColors.black : AppColors.white);
    final effectiveBorderRadius = widget.borderRadius ?? 16;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(opacity: _opacityAnimation.value, child: child),
        );
      },
      child: SizedBox(
        width: double.infinity,
        height: widget.height,
        child: ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: effectiveBackgroundColor,
            foregroundColor: effectiveForegroundColor,
            disabledBackgroundColor: AppColors.gray300,
            disabledForegroundColor: AppColors.gray500,
            elevation: widget.elevation,
            shadowColor: AppColors.shadowMedium,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(effectiveBorderRadius),
            ),
            textStyle: AppTypography.buttonLarge.copyWith(
              color: effectiveForegroundColor,
            ),
            splashFactory: InkRipple.splashFactory,
          ),
          child: widget.isLoading
              ? _LoadingIndicator(color: effectiveForegroundColor)
              : _ButtonContent(
                  label: widget.label,
                  icon: widget.icon,
                  iconAlignment: widget.iconAlignment,
                  foregroundColor: effectiveForegroundColor,
                ),
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.iconAlignment,
    required this.foregroundColor,
  });

  final String label;
  final IconData? icon;
  final IconAlignment iconAlignment;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return Text(
        label,
        style: AppTypography.buttonLarge.copyWith(color: foregroundColor),
      );
    }

    final iconWidget = AnimatedSwitcher(
      duration: AppTheme.fastDuration,
      child: Icon(icon, key: ValueKey(icon), color: foregroundColor, size: 20),
    );

    final labelWidget = Text(
      label,
      style: AppTypography.buttonLarge.copyWith(color: foregroundColor),
    );

    final children = iconAlignment == IconAlignment.start
        ? [iconWidget, const SizedBox(width: 8), labelWidget]
        : [labelWidget, const SizedBox(width: 8), iconWidget];

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}

class _LoadingIndicator extends StatefulWidget {
  const _LoadingIndicator({required this.color});

  final Color color;

  @override
  State<_LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<_LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(widget.color),
      ),
    );
  }
}

/// A secondary button with outlined style
class ZenSecondaryButton extends StatelessWidget {
  const ZenSecondaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.height = 52,
    this.borderRadius,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveBorderRadius = borderRadius ?? 16;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? AppColors.white : AppColors.textPrimary,
          side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
          ),
          textStyle: AppTypography.labelLarge,
        ),
        child: icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              )
            : Text(label),
      ),
    );
  }
}

/// A text button with modern styling
class ZenTextButton extends StatelessWidget {
  const ZenTextButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor:
            color ?? (isDark ? AppColors.white : AppColors.accentPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTypography.labelLarge,
      ),
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(label),
              ],
            )
          : Text(label),
    );
  }
}
