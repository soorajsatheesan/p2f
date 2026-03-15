import 'package:flutter/material.dart';

class P2fLogo extends StatelessWidget {
  const P2fLogo({
    super.key,
    required this.size,
    this.borderRadius,
    this.padding,
    this.backgroundColor = Colors.transparent,
  });

  final double size;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? size * 0.24;

    return Container(
      width: size,
      height: size,
      padding: padding ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Image.asset(
        'assets/images/p2f-logo.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
