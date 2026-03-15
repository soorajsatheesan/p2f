import 'package:flutter/material.dart';
import 'package:p2f/theme/theme.dart';

/// Monochrome card — rgba(255,255,255,0.02) bg, 0.08 border, 20px radius.
/// Hover: lift -8px, border brightens, subtle shadow.
class ZenCard extends StatefulWidget {
  const ZenCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
    this.margin = EdgeInsets.zero,
    this.radius = 20,
    this.enableHoverEffect = false,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double radius;
  final bool enableHoverEffect;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  State<ZenCard> createState() => _ZenCardState();
}

class _ZenCardState extends State<ZenCard>
    with SingleTickerProviderStateMixin {
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
      CurvedAnimation(parent: _controller, curve: AppTheme.primaryEasing),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enableHoverEffect) _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enableHoverEffect) _controller.reverse();
  }

  void _onTapCancel() {
    if (widget.enableHoverEffect) _controller.reverse();
  }

  void _onHover(bool isHovered) {
    if (widget.enableHoverEffect && mounted) {
      setState(() => _isHovered = isHovered);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColors.surface;
    final borderCol = widget.borderColor ?? AppColors.border;
    final hoverBorder = _isHovered ? AppColors.borderHover : borderCol;

    Widget card = AnimatedContainer(
      duration: AppTheme.fastDuration,
      curve: AppTheme.primaryEasing,
      width: double.infinity,
      padding: widget.padding,
      transform: _isHovered
          ? (Matrix4.identity()..translate(0.0, -8.0))
          : Matrix4.identity(),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: hoverBorder, width: 1),
        boxShadow: _isHovered
            ? const [
                BoxShadow(
                  color: AppColors.shadowCard,
                  blurRadius: 60,
                  offset: Offset(0, 24),
                ),
              ]
            : null,
      ),
      child: widget.child,
    );

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
                child: child,
              );
            },
            child: card,
          ),
        ),
      );
    }

    return Container(margin: widget.margin, child: card);
  }
}

/// Simple glass container for overlays
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.radius = 20,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: child,
    );
  }
}
