import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:p2f/theme/theme.dart';

/// A modern input field with floating labels, smooth animations,
/// and Material 3 styling.
///
/// Features:
/// - Animated floating label
/// - Modern focus states with smooth transitions
/// - Prefix/suffix icons with proper spacing
/// - Error state with shake animation
/// - Optional show/hide password toggle
class ZenInputField extends StatefulWidget {
  const ZenInputField({
    required this.controller,
    required this.onChanged,
    super.key,
    this.enabled = true,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.autofocus = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showClearButton = false,
    this.enablePasswordToggle = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool showClearButton;
  final bool enablePasswordToggle;

  @override
  State<ZenInputField> createState() => _ZenInputFieldState();
}

class _ZenInputFieldState extends State<ZenInputField>
    with SingleTickerProviderStateMixin {
  late final FocusNode _focusNode;
  late bool _isObscured;
  late final AnimationController _shakeController;
  String? _previousError;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _isObscured = widget.obscureText;
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(ZenInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != null && widget.errorText != _previousError) {
      _shakeController.forward(from: 0);
      _previousError = widget.errorText;
    } else if (widget.errorText == null) {
      _previousError = null;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _toggleObscure() {
    setState(() => _isObscured = !_isObscured);
  }

  void _clearText() {
    widget.controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget textField = TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      obscureText: _isObscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      autofocus: widget.autofocus,
      readOnly: widget.readOnly,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      style: AppTypography.input.copyWith(
        color: isDark ? AppColors.white : AppColors.textPrimary,
      ),
      cursorColor: isDark ? AppColors.white : AppColors.accentPrimary,
      cursorWidth: 2,
      cursorRadius: const Radius.circular(1),
      decoration: _buildDecoration(isDark),
    );

    // Wrap with shake animation if there's an error
    if (widget.errorText != null) {
      textField = AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final shake = _shakeController.value < 1.0
              ? _shakeController
                    .drive(
                      Tween<double>(
                        begin: 0,
                        end: 1,
                      ).chain(CurveTween(curve: const ShakeCurve())),
                    )
                    .value
              : 0.0;
          return Transform.translate(
            offset: Offset(shake * 8, 0),
            child: child,
          );
        },
        child: textField,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        textField,
        if (widget.errorText != null)
          AnimatedContainer(
            duration: AppTheme.fastDuration,
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 14,
                  color: isDark ? AppColors.errorLight : AppColors.error,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: AppTypography.errorText.copyWith(
                      color: isDark ? AppColors.errorLight : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  InputDecoration _buildDecoration(bool isDark) {
    final hasText = widget.controller.text.isNotEmpty;
    final isFocused = _focusNode.hasFocus;

    return InputDecoration(
      hintText: widget.hintText,
      labelText: widget.labelText,
      prefixIcon: widget.prefixIcon != null
          ? AnimatedContainer(
              duration: AppTheme.fastDuration,
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: IconTheme(
                data: IconThemeData(
                  color: isFocused
                      ? (isDark ? AppColors.white : AppColors.accentPrimary)
                      : AppColors.textTertiary,
                  size: 22,
                ),
                child: widget.prefixIcon!,
              ),
            )
          : null,
      suffixIcon: _buildSuffixIcon(isDark, isFocused),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? AppColors.white : AppColors.accentPrimary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? AppColors.errorLight : AppColors.error,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? AppColors.errorLight : AppColors.error,
          width: 2,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? AppColors.gray700 : AppColors.gray200,
          width: 1,
        ),
      ),
      filled: true,
      fillColor: !widget.enabled
          ? (isDark ? AppColors.gray800 : AppColors.gray50)
          : (isDark ? AppColors.gray800 : AppColors.gray50),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      hintStyle: AppTypography.inputHint,
      labelStyle: AppTypography.inputLabel,
      floatingLabelStyle: AppTypography.inputLabel.copyWith(
        color: isFocused
            ? (isDark ? AppColors.white : AppColors.accentPrimary)
            : AppColors.textSecondary,
        fontWeight: AppTypography.wSemibold,
      ),
      errorStyle: const TextStyle(height: 0, fontSize: 0),
    );
  }

  Widget? _buildSuffixIcon(bool isDark, bool isFocused) {
    final suffixWidgets = <Widget>[];

    // Clear button
    if (widget.showClearButton &&
        widget.controller.text.isNotEmpty &&
        !widget.obscureText) {
      suffixWidgets.add(
        IconButton(
          onPressed: _clearText,
          icon: Icon(
            Icons.close_rounded,
            size: 18,
            color: isDark ? AppColors.gray400 : AppColors.textTertiary,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          splashRadius: 16,
        ),
      );
    }

    // Password toggle
    if (widget.enablePasswordToggle && widget.obscureText) {
      suffixWidgets.add(
        IconButton(
          onPressed: _toggleObscure,
          icon: AnimatedSwitcher(
            duration: AppTheme.fastDuration,
            child: Icon(
              _isObscured
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              key: ValueKey<bool>(_isObscured),
              size: 20,
              color: isDark ? AppColors.gray400 : AppColors.textTertiary,
            ),
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          splashRadius: 16,
        ),
      );
    }

    // Custom suffix icon
    if (widget.suffixIcon != null) {
      suffixWidgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: widget.suffixIcon!,
        ),
      );
    }

    if (suffixWidgets.isEmpty) return null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [...suffixWidgets, const SizedBox(width: 12)],
    );
  }
}

/// A shake curve for error animations
class ShakeCurve extends Curve {
  const ShakeCurve();

  @override
  double transform(double t) {
    final sine = math.sin(t * math.pi * 6);
    final decay = 1 - t;
    return sine * decay;
  }
}

/// A modern search input field
class ZenSearchField extends StatelessWidget {
  const ZenSearchField({
    required this.controller,
    required this.onChanged,
    super.key,
    this.hintText = 'Search...',
    this.onClear,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;
  final VoidCallback? onClear;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ZenInputField(
      controller: controller,
      onChanged: onChanged,
      hintText: hintText,
      prefixIcon: const Icon(Icons.search),
      showClearButton: true,
      autofocus: autofocus,
    );
  }
}

/// A multiline text input with auto-expanding
class ZenTextArea extends StatelessWidget {
  const ZenTextArea({
    required this.controller,
    required this.onChanged,
    super.key,
    this.hintText,
    this.labelText,
    this.minLines = 3,
    this.maxLines = 6,
    this.maxLength,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final String? labelText;
  final int minLines;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return ZenInputField(
      controller: controller,
      onChanged: onChanged,
      hintText: hintText,
      labelText: labelText,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
    );
  }
}
