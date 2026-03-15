import 'package:flutter/material.dart';
import 'package:p2f/theme/theme.dart';
import 'package:p2f/widgets/global/animations.dart';
import 'package:p2f/widgets/global/p2f_logo.dart';

class FullBrandLogo extends StatelessWidget {
  const FullBrandLogo({
    super.key,
    this.logoSize = 110,
    this.animate = false,
    this.animation,
  });

  final double logoSize;

  /// If true, wraps each element in a [FadeSlideAnimation].
  /// Requires [animation] to be provided.
  final bool animate;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    final logo = P2fLogo(size: logoSize, borderRadius: 26);

    final brandText = Transform.translate(
      offset: const Offset(0, -8),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: AppTypography.tag.copyWith(
            fontSize: 11,
            letterSpacing: 3.5,
            height: 1.0,
          ),
          children: const [
            TextSpan(
              text: 'PATH2FITNESS',
              style: TextStyle(color: AppColors.foreground),
            ),
          ],
        ),
      ),
    );

    if (animate && animation != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeSlideAnimation(
            animation: CurvedAnimation(
              parent: animation!,
              curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
            ),
            slideBegin: const Offset(0, 24),
            child: logo,
          ),
          FadeSlideAnimation(
            animation: CurvedAnimation(
              parent: animation!,
              curve: const Interval(0.08, 0.48, curve: Curves.easeOut),
            ),
            slideBegin: const Offset(0, 12),
            child: brandText,
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [logo, brandText],
    );
  }
}
