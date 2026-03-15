import 'package:flutter/material.dart';
import 'package:p2f/theme/theme.dart';

/// Primary button — white fill, black text, pill shape (100px radius).
/// Hover: transparent bg, white text, lift -2px, glow shadow.
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
    this.elevation = 0,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final IconAlignment iconAlignment;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final double elevation;

  @override
  State<ZenPrimaryButton> createState() => _ZenPrimaryButtonState();
}

class _ZenPrimaryButtonState extends State<ZenPrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.985).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
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

  void _onTapUp(TapUpDetails details) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColors.foreground;
    final fgColor = widget.foregroundColor ?? AppColors.background;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: SizedBox(
        width: double.infinity,
        height: widget.height,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: ElevatedButton(
            onPressed: widget.isLoading ? () {} : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              foregroundColor: fgColor,
              disabledBackgroundColor: AppColors.surfaceElevated,
              disabledForegroundColor: AppColors.subtle,
              elevation: widget.elevation,
              padding: const EdgeInsets.symmetric(horizontal: 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
                side: BorderSide(color: bgColor, width: 1),
              ),
              textStyle: AppTypography.buttonLarge.copyWith(color: fgColor),
              splashFactory: InkRipple.splashFactory,
            ),
            child: widget.isLoading
                ? _LoadingIndicator(color: fgColor)
                : _ButtonContent(
                    label: widget.label,
                    icon: widget.icon,
                    iconAlignment: widget.iconAlignment,
                    foregroundColor: fgColor,
                  ),
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
        label.toUpperCase(),
        style: AppTypography.buttonLarge.copyWith(color: foregroundColor),
      );
    }

    final iconWidget = Icon(icon, color: foregroundColor, size: 20);
    final labelWidget = Text(
      label.toUpperCase(),
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

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

/// Ghost / outline button — transparent bg, white text, 0.25 border.
class ZenSecondaryButton extends StatelessWidget {
  const ZenSecondaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.foreground,
          side: const BorderSide(
            color: AppColors.borderHover, // 0.25 opacity
            width: 1,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
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
                  Text(label.toUpperCase()),
                ],
              )
            : Text(label.toUpperCase()),
      ),
    );
  }
}

/// Text button — monochrome
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
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color ?? AppColors.foreground,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        textStyle: AppTypography.labelLarge,
      ),
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(label.toUpperCase()),
              ],
            )
          : Text(label.toUpperCase()),
    );
  }
}
