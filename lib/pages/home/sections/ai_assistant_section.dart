import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2f/models/chat_message.dart';
import 'package:p2f/models/user_profile.dart';
import 'package:p2f/providers/ai_coach_provider.dart';
import 'package:p2f/services/chat_text_formatter.dart';
import 'package:p2f/theme/theme.dart';

class AiAssistantSection extends ConsumerWidget {
  const AiAssistantSection({required this.profile, super.key});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiCoachProvider);

    return AnimatedSwitcher(
      duration: AppTheme.normalDuration,
      switchInCurve: AppTheme.primaryEasing,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: AppTheme.primaryEasing),
          ),
          child: child,
        ),
      ),
      child: state.hasCompanion
          ? _ChatView(
              key: ValueKey(state.activeCompanion!.id),
              companion: state.activeCompanion!,
              profile: profile,
            )
          : const _CompanionSelector(key: ValueKey('selector')),
    );
  }
}

// ── Companion selector ────────────────────────────────────────────────────────

class _CompanionSelector extends ConsumerWidget {
  const _CompanionSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'AI COMPANION',
          style: AppTypography.tag.copyWith(
            color: AppColors.faint,
            letterSpacing: 2.5,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Choose your\nguide.',
          style: AppTypography.displaySmall.copyWith(
            fontSize: 40,
            height: 0.96,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Each companion brings a distinct coaching style and speciality.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.subtle,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        // 2 × 2 grid
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: Companion.all.map((companion) {
            return _CompanionCard(
              companion: companion,
              onTap: () {
                ref.read(aiCoachProvider.notifier).selectCompanion(companion);
              },
            );
          }).toList(),
        ),
      ],
    ),
    );
  }
}

class _CompanionCard extends StatefulWidget {
  const _CompanionCard({required this.companion, required this.onTap});

  final Companion companion;
  final VoidCallback onTap;

  @override
  State<_CompanionCard> createState() => _CompanionCardState();
}

class _CompanionCardState extends State<_CompanionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) {
        setState(() => _pressed = true);
        _ctrl.forward();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        _ctrl.reverse();
      },
      onTapCancel: () {
        setState(() => _pressed = false);
        _ctrl.reverse();
      },
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: AppTheme.primaryEasing,
          decoration: BoxDecoration(
            color: _pressed ? AppColors.surfaceHover : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _pressed ? AppColors.borderHover : AppColors.border,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image block
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0,      0,      0,      1, 0,
                        ]),
                        child: Image.asset(
                          widget.companion.imagePath,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ],
                  ),
                ),
                // Text block
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.companion.name,
                        style: AppTypography.titleMedium.copyWith(
                          fontSize: 20,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.companion.specialty.toUpperCase(),
                        style: AppTypography.tag.copyWith(
                          color: AppColors.faint,
                          fontSize: 9,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Chat view ─────────────────────────────────────────────────────────────────

class _ChatView extends ConsumerStatefulWidget {
  const _ChatView({
    required this.companion,
    required this.profile,
    super.key,
  });

  final Companion companion;
  final UserProfile? profile;

  @override
  ConsumerState<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<_ChatView> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();

    await ref.read(aiCoachProvider.notifier).sendMessage(
      userText: text,
      profile: widget.profile,
    );

    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: AppTheme.primaryEasing,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiCoachProvider);
    final companion = widget.companion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: [
        // ── Companion header ─────────────────────────────────────────────────
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0,      0,      0,      1, 0,
                ]),
                child: Image.asset(
                  companion.imagePath,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    companion.name,
                    style: AppTypography.titleSmall.copyWith(
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    companion.specialty.toUpperCase(),
                    style: AppTypography.tag.copyWith(
                      color: AppColors.faint,
                      fontSize: 9,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            // Switch companion
            GestureDetector(
              onTap: () =>
                  ref.read(aiCoachProvider.notifier).clearCompanion(),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  'SWITCH',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.subtle,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(height: 1, thickness: 1, color: AppColors.border),
        const SizedBox(height: 12),

        // ── Messages ─────────────────────────────────────────────────────────
        Expanded(
          child: state.isLoadingHistory
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.subtle,
                      ),
                    ),
                  ),
                )
              : state.messages.isEmpty
              ? Center(
                  child: Text(
                    'Start the conversation.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.faint,
                    ),
                  ),
                )
              : ListView.separated(
                  controller: _scrollCtrl,
                  itemCount: state.messages.length,
                  padding: EdgeInsets.zero,
                  separatorBuilder: (context, i) => const SizedBox(height: 10),
                  itemBuilder: (context, i) =>
                      _Bubble(message: state.messages[i]),
                ),
        ),

        // Sending indicator
        if (state.isSending) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.subtle),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${companion.name} is thinking…',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.faint,
                ),
              ),
            ],
          ),
        ],

        // Error
        if (state.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            state.errorMessage!,
            style: AppTypography.bodySmall.copyWith(color: AppColors.error),
          ),
        ],

        const SizedBox(height: 16),
        const Divider(height: 1, thickness: 1, color: AppColors.border),
        const SizedBox(height: 14),

        // ── Input ─────────────────────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _inputCtrl,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                style: AppTypography.input,
                cursorColor: AppColors.foreground,
                cursorWidth: 1.5,
                enabled: !state.isSending,
                decoration: InputDecoration(
                  hintText: 'Ask ${companion.name}…',
                  hintStyle: AppTypography.inputHint,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.foreground),
                  ),
                  disabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  filled: false,
                  contentPadding: const EdgeInsets.only(bottom: 10),
                  isDense: true,
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 14),
            // Send button
            GestureDetector(
              onTap: state.isSending ? null : _send,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: state.isSending
                      ? AppColors.surfaceElevated
                      : AppColors.foreground,
                  shape: BoxShape.circle,
                ),
                child: state.isSending
                    ? const SizedBox.shrink()
                    : const Icon(
                        Icons.arrow_upward_rounded,
                        color: AppColors.background,
                        size: 18,
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Chat bubble ───────────────────────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final displayText = isUser
        ? message.text
        : ChatTextFormatter.sanitizeAssistantText(message.text);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
            color: isUser ? AppColors.surfaceElevated : AppColors.surface,
            border: Border.all(
              color: isUser ? AppColors.borderHover : AppColors.border,
            ),
          ),
          child: Text(
            displayText,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.foreground,
              height: 1.55,
            ),
          ),
        ),
      ),
    );
  }
}
