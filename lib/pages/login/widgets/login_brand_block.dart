import 'package:flutter/material.dart';
import 'package:p2f/theme/theme.dart';

class LoginBrandBlock extends StatefulWidget {
  const LoginBrandBlock({super.key});

  @override
  State<LoginBrandBlock> createState() => _LoginBrandBlockState();
}

class _LoginBrandBlockState extends State<LoginBrandBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.015,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _opacity = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(scale: _scale.value, child: child),
        );
      },
      child: Text(
        'P2F',
        style: AppTypography.displaySmall.copyWith(
          fontSize: 40,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.2,
          color: isDark ? AppColors.white : AppColors.textPrimary,
        ),
      ),
    );
  }
}
