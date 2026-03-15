import 'package:flutter/material.dart';
import 'package:p2f/pages/login/widgets/login_terms_tile.dart';
import 'package:p2f/providers/login_provider.dart';
import 'package:p2f/theme/theme.dart';
import 'package:p2f/widgets/global/global_widgets.dart';

class LoginPageContent extends StatelessWidget {
  const LoginPageContent({
    required this.state,
    required this.apiKeyController,
    required this.onApiKeyChanged,
    required this.onClearApiKey,
    required this.onTermsChanged,
    required this.onSubmit,
    required this.onOpenApiGuide,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
    super.key,
  });

  final LoginState state;
  final TextEditingController apiKeyController;
  final ValueChanged<String> onApiKeyChanged;
  final VoidCallback onClearApiKey;
  final ValueChanged<bool?> onTermsChanged;
  final VoidCallback onSubmit;
  final Future<void> Function() onOpenApiGuide;
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final isCompactWidth = width < 380;
        final isShortHeight = height < 760 || keyboardVisible;
        final isVeryShortHeight = height < 700 || keyboardVisible;
        final useWideLayout = width >= 920 && height >= 620 && !keyboardVisible;

        if (useWideLayout) {
          return Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 56),
                      child: _HeroSection(
                        isCompact: false,
                        isShort: false,
                        isVeryShort: false,
                        showTrustPoints: true,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 420,
                    child: _ConnectKeyCard(
                      state: state,
                      apiKeyController: apiKeyController,
                      onApiKeyChanged: onApiKeyChanged,
                      onClearApiKey: onClearApiKey,
                      onTermsChanged: onTermsChanged,
                      onSubmit: onSubmit,
                      onOpenApiGuide: onOpenApiGuide,
                      onOpenTerms: onOpenTerms,
                      onOpenPrivacy: onOpenPrivacy,
                      isCompact: false,
                      isShort: false,
                      isVeryShort: false,
                      keyboardVisible: false,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              physics: keyboardVisible
                  ? const ClampingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                bottom: keyboardVisible
                    ? MediaQuery.of(context).viewInsets.bottom + 12
                    : 0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: keyboardVisible ? 0 : (isVeryShortHeight ? 0 : 4),
                    ),
                    Visibility(
                      visible: !keyboardVisible,
                      maintainState: true,
                      maintainAnimation: true,
                      maintainSize: false,
                      child: _HeroSection(
                        isCompact: isCompactWidth,
                        isShort: isShortHeight,
                        isVeryShort: isVeryShortHeight,
                        showTrustPoints: !isShortHeight,
                      ),
                    ),
                    SizedBox(
                      height: keyboardVisible
                          ? 4
                          : (isVeryShortHeight ? 8 : 12),
                    ),
                    _ConnectKeyCard(
                      state: state,
                      apiKeyController: apiKeyController,
                      onApiKeyChanged: onApiKeyChanged,
                      onClearApiKey: onClearApiKey,
                      onTermsChanged: onTermsChanged,
                      onSubmit: onSubmit,
                      onOpenApiGuide: onOpenApiGuide,
                      onOpenTerms: onOpenTerms,
                      onOpenPrivacy: onOpenPrivacy,
                      isCompact: isCompactWidth,
                      isShort: isShortHeight,
                      isVeryShort: isVeryShortHeight,
                      keyboardVisible: keyboardVisible,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Hero Section ────────────────────────────────────────────────────────────

class _HeroSection extends StatefulWidget {
  const _HeroSection({
    required this.isCompact,
    required this.isShort,
    required this.isVeryShort,
    this.showTrustPoints = true,
  });

  final bool isCompact;
  final bool isShort;
  final bool isVeryShort;
  final bool showTrustPoints;

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _anim(double begin, double end) => CurvedAnimation(
    parent: _controller,
    curve: Interval(begin, end, curve: AppTheme.primaryEasing),
  );

  @override
  Widget build(BuildContext context) {
    final heroFontSize = widget.isVeryShort
        ? 40.0
        : (widget.isCompact ? 46.0 : (widget.isShort ? 54.0 : 64.0));
    final outlineFontSize = widget.isVeryShort
        ? 26.0
        : (widget.isCompact ? 30.0 : (widget.isShort ? 38.0 : 48.0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo + brand name
        FullBrandLogo(
          logoSize: widget.isVeryShort ? 90 : 110,
          animate: true,
          animation: _controller,
        ),
        SizedBox(height: widget.isVeryShort ? 14 : 24),

        // "YOUR JOURNEY TO" line
        FadeSlideAnimation(
          animation: _anim(0.18, 0.58),
          slideBegin: const Offset(0, 20),
          child: Text(
            'YOUR JOURNEY TO',
            style: AppTypography.tag.copyWith(color: AppColors.subtle),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: widget.isVeryShort ? 4 : 6),

        // "FITNESS" — main hero
        FadeSlideAnimation(
          animation: _anim(0.23, 0.65),
          slideBegin: const Offset(0, 32),
          child: Text(
            'FITNESS',
            style: AppTypography.hero.copyWith(
              fontSize: heroFontSize,
              height: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: widget.isVeryShort ? 2 : 6),

        // "BEGINS TODAY" — outline
        FadeSlideAnimation(
          animation: _anim(0.3, 0.72),
          slideBegin: const Offset(0, 32),
          child: MonochromeOutlineText(
            text: 'BEGINS TODAY',
            textAlign: TextAlign.center,
            style: AppTypography.hero.copyWith(
              fontSize: outlineFontSize,
              height: 1.0,
              letterSpacing: 1.5,
            ),
            strokeWidth: widget.isVeryShort
                ? 1.2
                : (widget.isCompact ? 1.4 : 1.8),
          ),
        ),
        SizedBox(height: widget.isVeryShort ? 10 : 16),

        // Description
        FadeSlideAnimation(
          animation: _anim(0.42, 0.84),
          slideBegin: const Offset(0, 18),
          child: Text(
            'AI-powered nutrition tracking and coaching, running locally on your device.',
            style: AppTypography.bodyMedium.copyWith(
              fontSize: widget.isVeryShort
                  ? 13.0
                  : (widget.isShort ? 14.0 : 15.0),
              height: widget.isVeryShort ? 1.4 : 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ),

      ],
    );
  }
}

// ── Gradient-border Connect Card ─────────────────────────────────────────────

class _ConnectKeyCard extends StatefulWidget {
  const _ConnectKeyCard({
    required this.state,
    required this.apiKeyController,
    required this.onApiKeyChanged,
    required this.onClearApiKey,
    required this.onTermsChanged,
    required this.onSubmit,
    required this.onOpenApiGuide,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
    required this.isCompact,
    required this.isShort,
    required this.isVeryShort,
    required this.keyboardVisible,
  });

  final LoginState state;
  final TextEditingController apiKeyController;
  final ValueChanged<String> onApiKeyChanged;
  final VoidCallback onClearApiKey;
  final ValueChanged<bool?> onTermsChanged;
  final VoidCallback onSubmit;
  final Future<void> Function() onOpenApiGuide;
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;
  final bool isCompact;
  final bool isShort;
  final bool isVeryShort;
  final bool keyboardVisible;

  @override
  State<_ConnectKeyCard> createState() => _ConnectKeyCardState();
}

class _ConnectKeyCardState extends State<_ConnectKeyCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeOffset;

  bool get _hasValidationError =>
      widget.state.showApiKeyError || widget.state.showTermsError;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );
    _shakeOffset =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -10, end: 9), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 9, end: -7), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -7, end: 5), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 5, end: -3), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -3, end: 0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeOutCubic),
        );
  }

  @override
  void didUpdateWidget(covariant _ConnectKeyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hadError =
        oldWidget.state.showApiKeyError || oldWidget.state.showTermsError;
    if (!hadError && _hasValidationError) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compactForm = widget.keyboardVisible || widget.isVeryShort;
    final cardPadding = compactForm
        ? 14.0
        : (widget.isCompact || widget.isShort ? 20.0 : 28.0);

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeOffset.value, 0),
          child: child,
        );
      },
      child: _GradientBorderCard(
        borderRadius: 22,
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Card header row
            if (!widget.keyboardVisible) ...[
              _CardHeaderRow(
                isCompact: widget.isCompact,
                isShort: widget.isShort,
              ),
              SizedBox(height: widget.isVeryShort ? 6 : 10),
            ],

            // Heading
            Text(
              'OpenAI API Key',
              style: compactForm
                  ? AppTypography.titleLarge
                  : AppTypography.headlineSmall,
            ),

            // Divider
            if (!compactForm)
              const Padding(
                padding: EdgeInsets.only(top: 12, bottom: 4),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.border,
                ),
              ),
            SizedBox(height: compactForm ? 10 : 16),

            // API key input
            ZenInputField(
              controller: widget.apiKeyController,
              onChanged: widget.onApiKeyChanged,
              enabled: !widget.state.isLoading,
              obscureText: true,
              labelText: 'OpenAI API Key',
              hintText: 'sk-...',
              prefixIcon: const Icon(Icons.key_rounded),
              suffixIcon: widget.state.apiKey.isNotEmpty
                  ? IconButton(
                      onPressed: widget.onClearApiKey,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.subtle,
                        size: 18,
                      ),
                      splashRadius: 16,
                    )
                  : null,
              showClearButton: true,
              errorText:
                  widget.state.showApiKeyError && widget.state.apiKey.isEmpty
                  ? 'Please enter your API key'
                  : null,
            ),
            SizedBox(
              height: widget.keyboardVisible
                  ? 8
                  : (widget.isVeryShort ? 10 : 14),
            ),

            // Get key link
            TextButton.icon(
              onPressed: widget.onOpenApiGuide,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(
                Icons.open_in_new_rounded,
                size: 15,
                color: AppColors.muted,
              ),
              label: Text(
                compactForm || widget.isShort
                    ? 'GET OPENAI KEY'
                    : 'GENERATE KEY IN OPENAI PLATFORM',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.muted,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            SizedBox(
              height: widget.isVeryShort ? 2 : (widget.isCompact ? 4 : 8),
            ),

            // Terms checkbox
            LoginTermsTile(
              value: widget.state.termsAccepted,
              enabled: !widget.state.isLoading,
              onChanged: widget.onTermsChanged,
              showError:
                  widget.state.showTermsError && !widget.state.termsAccepted,
              onTermsTap: widget.onOpenTerms,
              onPrivacyTap: widget.onOpenPrivacy,
              compact: widget.isShort || widget.keyboardVisible,
            ),
            SizedBox(height: compactForm ? 10 : (widget.isCompact ? 16 : 22)),

            // Submit
            ZenPrimaryButton(
              label: widget.state.isLoading
                  ? 'Verifying...'
                  : 'Start your path',
              isLoading: widget.state.isLoading,
              onPressed: widget.state.isLoading ? null : widget.onSubmit,
              icon: widget.state.isLoading ? null : Icons.east_rounded,
              iconAlignment: IconAlignment.end,
              height: compactForm ? 48 : 56,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────────────

/// Card wrapper with a 1-pixel gradient border.
class _GradientBorderCard extends StatelessWidget {
  const _GradientBorderCard({
    required this.child,
    required this.borderRadius,
    required this.padding,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.borderStrong, AppColors.border, AppColors.faint],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: const EdgeInsets.all(1),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.overlayHeavy,
          borderRadius: BorderRadius.circular(borderRadius - 1),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Top row of the form card: "CONNECT" pill + shield icon.
class _CardHeaderRow extends StatelessWidget {
  const _CardHeaderRow({required this.isCompact, required this.isShort});

  final bool isCompact;
  final bool isShort;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.key_rounded, size: 11, color: AppColors.foreground),
              const SizedBox(width: 6),
              Text(
                'CONNECT',
                style: AppTypography.tag.copyWith(
                  fontSize: 10,
                  letterSpacing: 2.0,
                  color: AppColors.foreground,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        const Icon(Icons.shield_outlined, size: 15, color: AppColors.faint),
      ],
    );
  }
}

/// Security info badge below the input.
class _SecurityBadge extends StatelessWidget {
  const _SecurityBadge({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 14,
        vertical: isCompact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            size: isCompact ? 13 : 15,
            color: AppColors.subtle,
          ),
          SizedBox(width: isCompact ? 8 : 10),
          Expanded(
            child: Text(
              'Stored and encrypted on device only.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.muted,
                fontSize: isCompact ? 12 : 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
