import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2f/pages/login/widgets/login_page_content.dart';
import 'package:p2f/providers/login_provider.dart';
import 'package:p2f/theme/theme.dart';
import 'package:p2f/widgets/global/animations.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  static const String _apiKeyGuideUrl =
      'https://aistudio.google.com/app/apikey';

  late final TextEditingController _apiKeyController;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _openApiGuide() async {
    final uri = Uri.parse(_apiKeyGuideUrl);
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to open Google AI Studio right now.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showLegalPlaceholder(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark
          ? const Color(0xFF121827)
          : const Color(0xFFF8FAFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.headlineSmall.copyWith(
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Placeholder content for $title.\n\nFinal legal content will be added here.',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.gray400 : AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 380;
    final horizontalPadding = isCompact
        ? 16.0
        : (screenWidth < 420 ? 20.0 : 28.0);
    final verticalPadding = isCompact ? 22.0 : 34.0;

    if (_apiKeyController.text != state.apiKey) {
      _apiKeyController.value = TextEditingValue(
        text: state.apiKey,
        selection: TextSelection.collapsed(offset: state.apiKey.length),
      );
    }

    ref.listen<LoginState>(loginProvider, (previous, current) {
      final hadError = previous?.errorMessage;
      if (current.errorMessage != null && current.errorMessage != hadError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(current.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }

      if (current.isSuccess && previous?.isSuccess != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                const Text('API key verified successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const _LoginBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                verticalPadding,
              ),
              child: FadeSlideAnimation(
                animation: _animationController,
                child: LoginPageContent(
                  state: state,
                  apiKeyController: _apiKeyController,
                  onApiKeyChanged: notifier.updateApiKey,
                  onClearApiKey: () => notifier.updateApiKey(''),
                  onTermsChanged: notifier.updateTermsAccepted,
                  onSubmit: notifier.verifyAndLogin,
                  onOpenApiGuide: _openApiGuide,
                  onOpenTerms: () =>
                      _showLegalPlaceholder('Terms & Conditions'),
                  onOpenPrivacy: () => _showLegalPlaceholder('Privacy Policy'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginBackdrop extends StatefulWidget {
  const _LoginBackdrop();

  @override
  State<_LoginBackdrop> createState() => _LoginBackdropState();
}

class _LoginBackdropState extends State<_LoginBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 12000),
      vsync: this,
    )..repeat(reverse: true);
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
        final drift = (_controller.value - 0.5) * 2;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? AppColors.appGradientDark
                  : AppColors.appGradientLight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -120 + (drift * 10),
                right: -90 - (drift * 8),
                child: _BackdropOrb(
                  size: 320,
                  color: isDark
                      ? const Color(0x33315AA9)
                      : const Color(0x553A74E0),
                ),
              ),
              Positioned(
                bottom: -140 - (drift * 12),
                left: -110 + (drift * 10),
                child: _BackdropOrb(
                  size: 360,
                  color: isDark
                      ? const Color(0x33A1497B)
                      : const Color(0x55E88AB7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BackdropOrb extends StatelessWidget {
  const _BackdropOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
