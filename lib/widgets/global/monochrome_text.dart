import 'package:flutter/material.dart';
import 'package:p2f/theme/theme.dart';

class MonochromeOutlineText extends StatelessWidget {
  const MonochromeOutlineText({
    required this.text,
    required this.style,
    super.key,
    this.strokeWidth = 1.6,
    this.textAlign,
  });

  final String text;
  final TextStyle style;
  final double strokeWidth;
  final TextAlign? textAlign;

  TextStyle _styleWithForeground(Paint paint) {
    return TextStyle(
      inherit: style.inherit,
      debugLabel: style.debugLabel,
      fontFamily: style.fontFamily,
      fontFamilyFallback: style.fontFamilyFallback,
      fontSize: style.fontSize,
      fontWeight: style.fontWeight,
      fontStyle: style.fontStyle,
      letterSpacing: style.letterSpacing,
      wordSpacing: style.wordSpacing,
      textBaseline: style.textBaseline,
      height: style.height,
      leadingDistribution: style.leadingDistribution,
      locale: style.locale,
      background: style.background,
      shadows: style.shadows,
      fontFeatures: style.fontFeatures,
      fontVariations: style.fontVariations,
      decoration: style.decoration,
      decorationColor: style.decorationColor,
      decorationStyle: style.decorationStyle,
      decorationThickness: style.decorationThickness,
      overflow: style.overflow,
      foreground: paint,
    );
  }

  TextStyle _styleWithColor(Color color) {
    return TextStyle(
      inherit: style.inherit,
      debugLabel: style.debugLabel,
      fontFamily: style.fontFamily,
      fontFamilyFallback: style.fontFamilyFallback,
      fontSize: style.fontSize,
      fontWeight: style.fontWeight,
      fontStyle: style.fontStyle,
      letterSpacing: style.letterSpacing,
      wordSpacing: style.wordSpacing,
      textBaseline: style.textBaseline,
      height: style.height,
      leadingDistribution: style.leadingDistribution,
      locale: style.locale,
      background: style.background,
      shadows: style.shadows,
      fontFeatures: style.fontFeatures,
      fontVariations: style.fontVariations,
      decoration: style.decoration,
      decorationColor: style.decorationColor,
      decorationStyle: style.decorationStyle,
      decorationThickness: style.decorationThickness,
      overflow: style.overflow,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          textAlign: textAlign,
          style: _styleWithForeground(
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = AppColors.foreground,
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0x00FFFFFF),
                Color(0x20FFFFFF),
                Color(0x00FFFFFF),
              ],
              stops: [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: Text(
            text,
            textAlign: textAlign,
            style: _styleWithColor(AppColors.foreground.withValues(alpha: 0.08)),
          ),
        ),
      ],
    );
  }
}

class AnimatedStatNumber extends StatelessWidget {
  const AnimatedStatNumber({
    required this.value,
    required this.style,
    super.key,
    this.duration = const Duration(milliseconds: 1600),
    this.suffix,
  });

  final int value;
  final TextStyle style;
  final Duration duration;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: AppTheme.primaryEasing,
      builder: (context, animatedValue, _) {
        final rounded = animatedValue.round();
        return Text(
          suffix == null ? '$rounded' : '$rounded$suffix',
          style: style,
        );
      },
    );
  }
}
