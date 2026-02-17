import 'package:flutter/material.dart';
import 'package:p2f/pages/login/widgets/login_brand_block.dart';
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
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 380;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 6),
            const LoginBrandBlock(),
            SizedBox(height: isCompact ? 18 : 26),
            _HeroSection(isCompact: isCompact),
            SizedBox(height: isCompact ? 18 : 22),
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
              isCompact: isCompact,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your path to fitness',
          style: AppTypography.displaySmall.copyWith(
            fontSize: isCompact ? 34 : 44,
            height: 0.98,
            letterSpacing: -1.0,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ConnectKeyCard extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF9EBEFF) : const Color(0xFF2E63D3);

    return ZenCard(
      radius: 28,
      padding: EdgeInsets.all(isCompact ? 18 : 24),
      backgroundColor: isDark ? const Color(0xFF121826) : Colors.white,
      borderColor: isDark ? const Color(0xFF2E2A46) : const Color(0xFFD4DEF6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter Gemini API Key',
            style: AppTypography.headlineSmall.copyWith(
              color: isDark ? AppColors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: isCompact ? 12 : 14),
          ZenInputField(
            controller: apiKeyController,
            onChanged: onApiKeyChanged,
            enabled: !state.isLoading,
            obscureText: true,
            labelText: 'Gemini API Key',
            hintText: 'AIzaSy...',
            prefixIcon: Icon(Icons.key_rounded, color: accent),
            suffixIcon: state.apiKey.isNotEmpty
                ? IconButton(
                    onPressed: onClearApiKey,
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark
                          ? AppColors.gray400
                          : AppColors.textTertiary,
                      size: 18,
                    ),
                    splashRadius: 16,
                  )
                : null,
            showClearButton: true,
            errorText: state.showApiKeyError && state.apiKey.isEmpty
                ? 'Please enter your API key'
                : null,
          ),
          SizedBox(height: isCompact ? 12 : 14),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isCompact ? 12 : 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFFEAF8EF),
              border: Border.all(color: const Color(0xFFB7E4C2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  size: 18,
                  color: Color(0xFF1F8A4C),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Stored and encrypted on device only.',
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF1F8A4C),
                      fontWeight: AppTypography.wSemibold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isCompact ? 8 : 10),
          TextButton.icon(
            onPressed: onOpenApiGuide,
            icon: Icon(Icons.open_in_new_rounded, size: 16, color: accent),
            label: Text(
              'Generate key in Google AI Studio',
              style: AppTypography.labelLarge.copyWith(color: accent),
            ),
          ),
          SizedBox(height: isCompact ? 6 : 8),
          LoginTermsTile(
            value: state.termsAccepted,
            enabled: !state.isLoading,
            onChanged: onTermsChanged,
            showError: state.showTermsError && !state.termsAccepted,
            onTermsTap: onOpenTerms,
            onPrivacyTap: onOpenPrivacy,
          ),
          SizedBox(height: isCompact ? 16 : 20),
          ZenPrimaryButton(
            label: state.isLoading ? 'Verifying key...' : 'Start your path',
            isLoading: state.isLoading,
            onPressed: state.isFormValid ? onSubmit : null,
            icon: state.isLoading ? null : Icons.east_rounded,
            iconAlignment: IconAlignment.end,
            backgroundColor: accent,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
