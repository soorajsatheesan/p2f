import 'package:flutter/material.dart';
import 'package:p2f/theme/theme.dart';

/// Monochrome atmospheric background that stays within the black/white palette.
class AppGradientBackground extends StatelessWidget {
  const AppGradientBackground({
    super.key,
    this.child,
    this.padding,
  });

  final Widget? child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final content = child;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background,
            Color(0xFF030303),
            AppColors.background,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -80,
            left: -40,
            child: IgnorePointer(
              child: Container(
                width: 240,
                height: 240,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x1AFFFFFF),
                      Color(0x05000000),
                      Color(0x00000000),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -70,
            bottom: -120,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x12FFFFFF),
                      Color(0x04000000),
                      Color(0x00000000),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.transparent,
                      AppColors.transparent,
                      AppColors.overlayFade.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (content != null)
            Padding(
              padding: padding ?? EdgeInsets.zero,
              child: content,
            ),
        ],
      ),
    );
  }
}
