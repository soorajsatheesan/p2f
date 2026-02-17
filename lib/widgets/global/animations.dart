import 'package:flutter/material.dart';
import 'package:p2f/theme/theme.dart';

/// A collection of modern animation utilities and widgets
/// for smooth, polished transitions.

/// Fade and slide animation wrapper
class FadeSlideAnimation extends StatelessWidget {
  const FadeSlideAnimation({
    required this.child,
    required this.animation,
    this.slideBegin = const Offset(0, 20),
    super.key,
  });

  final Widget child;
  final Animation<double> animation;
  final Offset slideBegin;

  @override
  Widget build(BuildContext context) {
    final slideAnimation = Tween<Offset>(
      begin: slideBegin,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    final fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(position: slideAnimation, child: child),
    );
  }
}

/// Staggered list animation builder
class StaggeredListAnimation extends StatelessWidget {
  const StaggeredListAnimation({
    required this.children,
    required this.animation,
    this.itemDelay = 0.1,
    this.slideBegin = const Offset(0, 30),
    super.key,
  });

  final List<Widget> children;
  final Animation<double> animation;
  final double itemDelay;
  final Offset slideBegin;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;

        final intervalStart = index * itemDelay;
        final intervalEnd =
            intervalStart +
            (1 - (children.length - 1) * itemDelay).clamp(0.3, 0.6);

        final itemAnimation = CurvedAnimation(
          parent: animation,
          curve: Interval(
            intervalStart.clamp(0.0, 0.9),
            intervalEnd.clamp(0.3, 1.0),
            curve: Curves.easeOutCubic,
          ),
        );

        return FadeSlideAnimation(
          animation: itemAnimation,
          slideBegin: slideBegin,
          child: child,
        );
      }).toList(),
    );
  }
}

/// Scale animation wrapper
class ScaleAnimation extends StatelessWidget {
  const ScaleAnimation({
    required this.child,
    required this.animation,
    this.scaleBegin = 0.9,
    super.key,
  });

  final Widget child;
  final Animation<double> animation;
  final double scaleBegin;

  @override
  Widget build(BuildContext context) {
    final scaleAnimation = Tween<double>(
      begin: scaleBegin,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack));

    final fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(scale: scaleAnimation, child: child),
    );
  }
}

/// Animated page route with slide transition
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  SlidePageRoute({required this.child, this.direction = AxisDirection.right})
    : super(
        transitionDuration: AppTheme.normalDuration,
        reverseTransitionDuration: AppTheme.normalDuration,
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          Offset begin;
          switch (direction) {
            case AxisDirection.up:
              begin = const Offset(0, 1);
              break;
            case AxisDirection.down:
              begin = const Offset(0, -1);
              break;
            case AxisDirection.left:
              begin = const Offset(-1, 0);
              break;
            case AxisDirection.right:
              begin = const Offset(1, 0);
              break;
          }

          return SlideTransition(
            position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      );

  final Widget child;
  final AxisDirection direction;
}

/// Animated page route with fade transition
class FadePageRoute<T> extends PageRouteBuilder<T> {
  FadePageRoute({required this.child})
    : super(
        transitionDuration: AppTheme.slowDuration,
        reverseTransitionDuration: AppTheme.normalDuration,
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      );

  final Widget child;
}

/// Pulse animation for attention-grabbing elements
class PulseAnimation extends StatefulWidget {
  const PulseAnimation({
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 2000),
    this.minScale = 0.98,
    this.maxScale = 1.02,
  });

  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = Tween<double>(
          begin: widget.minScale,
          end: widget.maxScale,
        ).evaluate(_controller);

        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );
  }
}

/// Shimmer loading effect
class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({required this.child, super.key});

  final Widget child;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + _controller.value * 2, 0),
              end: Alignment(1.0 + _controller.value * 2, 0),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Animated container with smooth transitions
class AnimatedContainerModern extends StatelessWidget {
  const AnimatedContainerModern({
    required this.child,
    required this.isExpanded,
    super.key,
    this.duration = AppTheme.normalDuration,
    this.curve = Curves.easeInOutCubic,
  });

  final Widget child;
  final bool isExpanded;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: curve,
        switchOutCurve: curve,
        child: isExpanded ? child : const SizedBox.shrink(),
      ),
    );
  }
}

/// Skeleton loading placeholder
class Skeleton extends StatelessWidget {
  const Skeleton({
    super.key,
    this.height = 16,
    this.width = double.infinity,
    this.borderRadius = 8,
  });

  final double height;
  final double width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Animated icon button with scale effect
class AnimatedIconButton extends StatefulWidget {
  const AnimatedIconButton({
    required this.icon,
    required this.onPressed,
    super.key,
    this.size = 24,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.fastDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
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

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = Tween<double>(
            begin: 1.0,
            end: 0.85,
          ).evaluate(_controller);
          return Transform.scale(scale: scale, child: child);
        },
        child: Icon(
          widget.icon,
          size: widget.size,
          color:
              widget.color ??
              (isDark ? AppColors.white : AppColors.textPrimary),
        ),
      ),
    );
  }
}
