// lib/features/chat/presentation/widgets/chat_message_bubble.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';

/// Chat message bubble that displays user or AI messages
/// User messages align right, AI messages align left
class ChatMessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isUser
                ? (isDark
                      ? AppColorsDark.primaryText
                      : AppColorsLight.primaryText)
                : (isDark
                      ? AppColorsDark.lightBackground
                      : AppColorsLight.lightBackground),
            border: isUser
                ? null
                : Border.all(
                    color: isDark
                        ? AppColorsDark.border
                        : AppColorsLight.border,
                  ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.lg),
              topRight: Radius.circular(AppRadius.lg),
              bottomLeft: Radius.circular(isUser ? AppRadius.lg : AppRadius.sm),
              bottomRight: Radius.circular(
                isUser ? AppRadius.sm : AppRadius.lg,
              ),
            ),
          ),
          child: Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isUser
                  ? (isDark
                        ? AppColorsDark.background
                        : AppColorsLight.background)
                  : (isDark
                        ? AppColorsDark.primaryText
                        : AppColorsLight.primaryText),
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
