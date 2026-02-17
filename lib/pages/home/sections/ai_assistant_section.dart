import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2f/models/chat_message.dart';
import 'package:p2f/models/user_profile.dart';
import 'package:p2f/providers/ai_coach_provider.dart';
import 'package:p2f/theme/theme.dart';
import 'package:p2f/widgets/global/global_widgets.dart';

class AiAssistantSection extends ConsumerStatefulWidget {
  const AiAssistantSection({required this.profile, super.key});

  final UserProfile? profile;

  @override
  ConsumerState<AiAssistantSection> createState() => _AiAssistantSectionState();
}

class _AiAssistantSectionState extends ConsumerState<AiAssistantSection> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();
    await ref
        .read(aiCoachProvider.notifier)
        .sendMessage(userText: text, profile: widget.profile);

    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiCoachProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ZenCard(
          radius: 24,
          backgroundColor: isDark ? const Color(0xFF1A2438) : AppColors.surface,
          borderColor: isDark
              ? const Color(0xFF2D3E61)
              : const Color(0xFFD8E2F8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Assistant - Joe',
                style: AppTypography.headlineSmall.copyWith(
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Health-only coaching chat based on your profile.',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.gray400 : AppColors.textSecondary,
                ),
              ),
              if (widget.profile == null) ...[
                const SizedBox(height: 8),
                Text(
                  'Tip: complete your profile for better personalized guidance.',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? const Color(0xFF9EBEFF) : AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        ZenCard(
          radius: 24,
          backgroundColor: isDark ? const Color(0xFF1A2438) : AppColors.surface,
          borderColor: isDark
              ? const Color(0xFF2D3E61)
              : const Color(0xFFD8E2F8),
          child: Column(
            children: [
              SizedBox(
                height: 420,
                child: ListView.separated(
                  controller: _scrollController,
                  itemCount: state.messages.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    return _ChatBubble(message: message);
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText:
                            'Ask Joe about training, nutrition, recovery...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: state.isSending ? null : _send,
                    icon: state.isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    state.errorMessage!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.role == ChatRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isUser
                ? (isDark ? const Color(0xFF284B8E) : const Color(0xFFE3ECFF))
                : (isDark ? AppColors.gray800 : AppColors.gray50),
            border: Border.all(
              color: isUser
                  ? (isDark ? const Color(0xFF4A78D3) : const Color(0xFFBED1FF))
                  : (isDark ? AppColors.borderDark : AppColors.border),
            ),
          ),
          child: Text(
            message.text,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.gray200 : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
