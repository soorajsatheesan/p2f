import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2f/pages/login/widgets/login_page_content.dart';
import 'package:p2f/providers/login_provider.dart';
import 'package:p2f/theme/theme.dart';
import 'package:p2f/widgets/global/global_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class _LegalSection {
  const _LegalSection({required this.heading, required this.body});

  final String heading;
  final String body;
}

class _LegalDocument {
  const _LegalDocument({
    required this.title,
    required this.intro,
    required this.sections,
  });

  final String title;
  final String intro;
  final List<_LegalSection> sections;
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  static const String _apiKeyGuideUrl = 'https://platform.openai.com/api-keys';
  static const String _loginBackgroundImageAsset =
      'assets/images/login-background.jpg';
  static const String _effectiveDate = 'March 13, 2026';
  static const _LegalDocument _termsDocument = _LegalDocument(
    title: 'Terms & Conditions',
    intro:
        'Effective date: $_effectiveDate\n\nP2F is an open-source, local-first fitness application. By using P2F, you agree to these Terms & Conditions. If you do not agree, do not use the app.',
    sections: [
      _LegalSection(
        heading: 'Use at your own risk',
        body:
            'P2F is provided on an "as is" and "as available" basis without warranties of any kind. You use the app entirely at your own risk. The developer does not promise uninterrupted service, error-free output, fitness results, health outcomes, or compatibility with every device.',
      ),
      _LegalSection(
        heading: 'Your responsibility',
        body:
            'You are solely responsible for your account setup, API key, device security, local backups, nutrition logs, prompts, uploaded images, and any actions you take based on the app’s output. You are also responsible for reviewing AI-generated responses before relying on them.',
      ),
      _LegalSection(
        heading: 'Health disclaimer',
        body:
            'P2F is not medical care and does not provide diagnosis, treatment, emergency support, or professional advice. Any workout, nutrition, recovery, or lifestyle suggestion is informational only. You must use your own judgment and consult a qualified professional where appropriate.',
      ),
      _LegalSection(
        heading: 'Local-first storage',
        body:
            'P2F is designed to store most app data locally on your device. That includes items such as your profile, nutrition history, and saved app state. Because the data stays on your device, you are primarily responsible for maintaining device security, handling data loss, and managing deletion or retention.',
      ),
      _LegalSection(
        heading: 'OpenAI-powered features',
        body:
            'Some features send limited user-provided content to OpenAI so the app can generate AI responses. Depending on the feature, that may include prompts, chat messages, profile details you choose to enter, meal descriptions, and nutrition images you choose to analyze. Those transmissions are necessary for the AI feature to work.',
      ),
      _LegalSection(
        heading: 'Third-party services',
        body:
            'OpenAI is a third-party service provider. The developer does not control OpenAI’s systems, uptime, security operations, or retention practices. Your use of AI features is also subject to OpenAI’s own terms, policies, and technical limitations.',
      ),
      _LegalSection(
        heading: 'No developer liability',
        body:
            'To the maximum extent allowed by law, the developer will not be liable for indirect, incidental, special, consequential, exemplary, or punitive damages, or for loss of data, loss of profits, health-related decisions, device issues, service interruptions, inaccurate AI output, or third-party service failures arising from or related to your use of P2F.',
      ),
      _LegalSection(
        heading: 'Open-source nature',
        body:
            'Because P2F is open source, the software may be modified, forked, or self-hosted by others. The developer is not responsible for third-party builds, modifications, redistributions, or deployments that are not directly released by the developer.',
      ),
      _LegalSection(
        heading: 'Changes',
        body:
            'These terms may be updated in future releases. Continued use of the app after an update means you accept the revised terms.',
      ),
    ],
  );
  static const _LegalDocument _privacyDocument = _LegalDocument(
    title: 'Privacy Policy',
    intro:
        'Effective date: $_effectiveDate\n\nThis Privacy Policy explains how P2F handles information. P2F is built as a local-first application, so most information is stored on your device rather than on developer-controlled servers.',
    sections: [
      _LegalSection(
        heading: 'What P2F stores locally',
        body:
            'P2F stores most app information locally on your device. Based on the current app behavior, this may include your profile information, nutrition history, meal descriptions, image paths, and your OpenAI API key stored through device-secured storage mechanisms.',
      ),
      _LegalSection(
        heading: 'What may be sent to OpenAI',
        body:
            'When you use AI features, P2F may send selected content to OpenAI to process your request. This can include prompts, chat content, profile context used for personalization, meal descriptions, and images submitted for nutrition analysis. If you do not want that data sent to OpenAI, do not use those AI features.',
      ),
      _LegalSection(
        heading: 'How OpenAI handles API data',
        body:
            'According to OpenAI’s current API data documentation, API data is not used to train OpenAI models by default unless the customer explicitly opts in to share data. OpenAI may still retain certain API data for abuse monitoring or operational reasons under its own policies. OpenAI’s practices can change, so you should review OpenAI’s current policies yourself before use.',
      ),
      _LegalSection(
        heading: 'No developer cloud database',
        body:
            'P2F does not appear to operate a developer-managed central cloud database for your ordinary app content. As a result, the developer generally does not have routine access to your locally stored profile, nutrition history, or API key just because you use the app.',
      ),
      _LegalSection(
        heading: 'Your control and responsibility',
        body:
            'Because data is primarily stored locally, you are responsible for your device security, passcodes, backups, deletions, exports, screenshots, and any sharing you choose to do. Deleting the app or clearing local storage may permanently remove your information from your device.',
      ),
      _LegalSection(
        heading: 'No guarantee of absolute security',
        body:
            'No app, device, or network transmission is perfectly secure. While P2F uses local storage patterns and relies on OpenAI for API transport to its systems, the developer cannot guarantee absolute security and is not responsible for unauthorized access caused by device compromise, user error, third-party breaches, or network conditions.',
      ),
      _LegalSection(
        heading: 'Children',
        body:
            'P2F is not intended for children to use without appropriate supervision and consent where required by law. You are responsible for ensuring that your use of the app is lawful in your location.',
      ),
      _LegalSection(
        heading: 'Policy updates',
        body:
            'This Privacy Policy may be revised in future releases. The version included in the app applies from the effective date shown above until updated.',
      ),
    ],
  );

  late final TextEditingController _apiKeyController;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _animationController = AnimationController(
      duration: AppTheme.slowDuration,
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
        _errorSnackBar('Unable to open OpenAI API keys right now.'),
      );
    }
  }

  void _showLegalDocument(_LegalDocument document) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final bottomInset = MediaQuery.of(context).padding.bottom;
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 18, 24, 24 + bottomInset),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.84,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          document.title,
                          style: AppTypography.headlineSmall,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        color: AppColors.foreground,
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            document.intro,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.muted,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 18),
                          for (final section in document.sections) ...[
                            Text(
                              section.heading,
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.foreground,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              section.body,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.muted,
                                height: 1.55,
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final keyboardVisible = keyboardInset > 0;
    final isCompact = screenWidth < 380;
    final horizontalPadding = isCompact
        ? 16.0
        : (screenWidth < 420 ? 20.0 : 24.0);
    final restingVerticalPadding = isCompact ? 22.0 : 34.0;
    final verticalPadding = keyboardVisible ? 8.0 : restingVerticalPadding;

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
          _errorSnackBar(current.errorMessage!),
        );
      }

      if (current.isSuccess && previous?.isSuccess != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          _successSnackBar('API key verified successfully'),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: AppGradientBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: _LoginBackgroundImage(
                  imageAsset: _loginBackgroundImageAsset,
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.overlayHeavy.withOpacity(0.42),
                        AppColors.overlayHeavy.withOpacity(0.18),
                        AppColors.overlayHeavy.withOpacity(0.46),
                      ],
                      stops: const [0.0, 0.5, 1.0],
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
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.overlayFade.withOpacity(0.76),
                        AppColors.overlayHeavy.withOpacity(0.28),
                        AppColors.transparent,
                      ],
                      stops: const [0.0, 0.42, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  verticalPadding,
                ),
                child: SizedBox.expand(
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
                          _showLegalDocument(_termsDocument),
                      onOpenPrivacy: () =>
                          _showLegalDocument(_privacyDocument),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginBackgroundImage extends StatelessWidget {
  const _LoginBackgroundImage({required this.imageAsset});

  final String imageAsset;

  static const List<double> _grayscaleMatrix = <double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
      child: Image.asset(
        imageAsset,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

// ── Snackbar helpers ──────────────────────────────────────────────────────────

SnackBar _successSnackBar(String message) => SnackBar(
  content: Row(
    children: [
      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          message,
          style: const TextStyle(color: AppColors.foreground),
        ),
      ),
    ],
  ),
  backgroundColor: const Color(0xFF071A09),
  behavior: SnackBarBehavior.floating,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  duration: const Duration(seconds: 3),
);

SnackBar _errorSnackBar(String message) => SnackBar(
  content: Row(
    children: [
      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 16),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          message,
          style: const TextStyle(color: AppColors.foreground),
        ),
      ),
    ],
  ),
  backgroundColor: const Color(0xFF1A0707),
  behavior: SnackBarBehavior.floating,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  duration: const Duration(seconds: 4),
);
