import 'package:flutter/material.dart';
import 'package:p2f/theme/theme.dart';

/// A modern card widget with glassmorphism effects, layered shadows,
/// and smooth animations.
///
/// Features:
/// - Subtle glassmorphism with optional blur effect
/// - Layered shadow system for depth
/// - Smooth hover/press animations
/// - Configurable border radius and padding
class ZenCard extends StatefulWidget {
  const ZenCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.radius = 20,
    this.elevation = 0,
    this.enableGlassmorphism = false,
    this.enableHoverEffect = false,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.shadowColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double radius;
  final double elevation;
  final bool enableGlassmorphism;
  final bool enableHoverEffect;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? shadowColor;

  @override
  State<ZenCard> createState() => _ZenCardState();
}

class _ZenCardState extends State<ZenCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.fastDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enableHoverEffect) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enableHoverEffect) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.enableHoverEffect) {
      _controller.reverse();
    }
  }

  void _onHover(bool isHovered) {
    if (widget.enableHoverEffect && mounted) {
      setState(() => _isHovered = isHovered);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget card = Container(
      width: double.infinity,
      padding: widget.padding,
      decoration: BoxDecoration(
        color:
            widget.backgroundColor ??
            (widget.enableGlassmorphism
                ? (isDark ? AppColors.glassDark : AppColors.glassLight)
                : AppColors.surface),
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(
          color:
              widget.borderColor ??
              (isDark ? AppColors.borderDark : AppColors.border),
          width: 1,
        ),
        boxShadow: _buildShadows(isDark),
      ),
      child: widget.child,
    );

    if (widget.enableGlassmorphism) {
      card = ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: card,
      );
    }

    if (widget.onTap != null || widget.enableHoverEffect) {
      card = MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: widget.onTap != null ? _onTapDown : null,
          onTapUp: widget.onTap != null ? _onTapUp : null,
          onTapCancel: widget.onTap != null ? _onTapCancel : null,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: AnimatedContainer(
                  duration: AppTheme.fastDuration,
                  margin: widget.margin,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.radius),
                    boxShadow: _isHovered && widget.enableHoverEffect
                        ? _buildHoverShadows(isDark)
                        : null,
                  ),
                  child: child,
                ),
              );
            },
            child: card,
          ),
        ),
      );
    } else {
      card = Container(margin: widget.margin, child: card);
    }

    return card;
  }

  List<BoxShadow> _buildShadows(bool isDark) {
    if (widget.elevation > 0) {
      return [
        BoxShadow(
          color: widget.shadowColor ?? AppColors.shadowMedium,
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: widget.shadowColor ?? AppColors.shadowLight,
          blurRadius: 40,
          offset: const Offset(0, 16),
          spreadRadius: -8,
        ),
      ];
    }

    // Subtle ambient shadow for depth without elevation
    return [
      BoxShadow(
        color: widget.shadowColor ?? AppColors.shadowLight,
        blurRadius: 12,
        offset: const Offset(0, 4),
        spreadRadius: -4,
      ),
    ];
  }

  List<BoxShadow> _buildHoverShadows(bool isDark) {
    return [
      BoxShadow(
        color: widget.shadowColor ?? AppColors.shadowMedium,
        blurRadius: 24,
        offset: const Offset(0, 12),
        spreadRadius: -4,
      ),
      BoxShadow(
        color: widget.shadowColor ?? AppColors.shadowLight,
        blurRadius: 48,
        offset: const Offset(0, 24),
        spreadRadius: -8,
      ),
    ];
  }
}

/// A subtle glass container for overlay effects
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.radius = 16,
    this.borderColor,
    this.backgroundColor,
    this.blurSigma = 10.0,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double radius;
  final Color? borderColor;
  final Color? backgroundColor;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (isDark ? AppColors.glassDark : AppColors.glassLight),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color:
              borderColor ?? (isDark ? AppColors.borderDark : AppColors.border),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
