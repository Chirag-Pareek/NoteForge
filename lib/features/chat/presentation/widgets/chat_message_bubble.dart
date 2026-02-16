// lib/features/chat/presentation/widgets/chat_message_bubble.dart

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_effects.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/compose_attachment.dart';

/// Chat message bubble that displays user or AI messages.
/// User messages align right, AI messages align left.
class ChatMessageBubble extends StatelessWidget {
  static const Set<String> _imageExtensions = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'bmp',
  };

  final String message;
  final bool isUser;
  final DateTime timestamp;
  final List<ComposeAttachment> attachments;
  final bool isGroupedWithPrevious;
  final bool isGroupedWithNext;
  final bool showTimestamp;
  final bool isTypingIndicator;
  final bool showStreamingCursor;
  final double maxBubbleWidth;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.attachments = const <ComposeAttachment>[],
    this.isGroupedWithPrevious = false,
    this.isGroupedWithNext = false,
    this.showTimestamp = false,
    this.isTypingIndicator = false,
    this.showStreamingCursor = false,
    this.maxBubbleWidth = 620,
  });

  bool _isImageAttachment(ComposeAttachment attachment) {
    return _imageExtensions.contains(attachment.extension.toLowerCase());
  }

  bool _isPdfAttachment(ComposeAttachment attachment) {
    return attachment.extension.toLowerCase() == 'pdf';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topSpacing = isGroupedWithPrevious ? AppSpacing.xs : AppSpacing.md;
    final bottomSpacing = showTimestamp
        ? AppSpacing.md
        : (isGroupedWithNext ? AppSpacing.xs : AppSpacing.sm);
    final timestampText = TimeOfDay.fromDateTime(timestamp).format(context);
    final hasText = message.trim().isNotEmpty;
    final hasAttachments = attachments.isNotEmpty;
    final messageTextColor = isUser
        ? (isDark ? AppColorsDark.background : AppColorsLight.background)
        : (isDark ? AppColorsDark.primaryText : AppColorsLight.primaryText);

    return Padding(
      padding: EdgeInsets.only(top: topSpacing, bottom: bottomSpacing),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              constraints: BoxConstraints(maxWidth: maxBubbleWidth),
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
                borderRadius: _buildBubbleRadius(),
                boxShadow: AppEffects.subtleDepth(Theme.of(context).brightness),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isTypingIndicator)
                    _TypingDots(
                      color: isDark
                          ? AppColorsDark.secondaryText
                          : AppColorsLight.secondaryText,
                    ),
                  if (!isTypingIndicator && hasText)
                    _buildMessageText(messageTextColor),
                  if (hasText && hasAttachments)
                    const SizedBox(height: AppSpacing.sm),
                  if (hasAttachments) _buildAttachmentPreview(context, isDark),
                ],
              ),
            ),
            if (showTimestamp && !isTypingIndicator)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  timestampText,
                  style: AppTextStyles.label.copyWith(
                    color: isDark
                        ? AppColorsDark.secondaryText
                        : AppColorsLight.secondaryText,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageText(Color color) {
    final messageStyle = AppTextStyles.bodyMedium.copyWith(
      color: color,
      height: 1.5,
    );
    if (!showStreamingCursor) {
      return Text(message, style: messageStyle);
    }

    return RichText(
      text: TextSpan(
        style: messageStyle,
        children: [
          TextSpan(text: message),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _BlinkingCursor(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentPreview(BuildContext context, bool isDark) {
    final imageAttachments = attachments.where(_isImageAttachment).toList();
    final pdfAttachments = attachments.where(_isPdfAttachment).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageAttachments.isNotEmpty)
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: imageAttachments
                .map(
                  (attachment) => _buildImagePreviewCard(context, attachment),
                )
                .toList(growable: false),
          ),
        if (imageAttachments.isNotEmpty && pdfAttachments.isNotEmpty)
          const SizedBox(height: AppSpacing.sm),
        if (pdfAttachments.isNotEmpty)
          Column(
            children: pdfAttachments
                .map(
                  (attachment) =>
                      _buildPdfPreviewCard(context, attachment, isDark),
                )
                .toList(growable: false),
          ),
      ],
    );
  }

  Widget _buildImagePreviewCard(
    BuildContext context,
    ComposeAttachment attachment,
  ) {
    final cardWidth = (maxBubbleWidth * 0.44).clamp(120.0, 220.0);

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: () => _showImageDialog(context, attachment),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Image.file(
          File(attachment.path),
          width: cardWidth,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: cardWidth,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported_outlined),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPdfPreviewCard(
    BuildContext context,
    ComposeAttachment attachment,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => _showPdfDialog(context, attachment),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isDark ? AppColorsDark.border : AppColorsLight.border,
            ),
            color: isDark
                ? AppColorsDark.background
                : AppColorsLight.background,
          ),
          child: Row(
            children: [
              Icon(
                Icons.picture_as_pdf_outlined,
                size: 18,
                color: isDark
                    ? AppColorsDark.secondaryText
                    : AppColorsLight.secondaryText,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColorsDark.primaryText
                        : AppColorsLight.primaryText,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.open_in_new,
                size: 14,
                color: isDark
                    ? AppColorsDark.secondaryText
                    : AppColorsLight.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, ComposeAttachment attachment) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Image.file(
              File(attachment.path),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                height: 180,
                child: Center(child: Icon(Icons.image_not_supported_outlined)),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPdfDialog(BuildContext context, ComposeAttachment attachment) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(attachment.name, style: AppTextStyles.bodyLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'PDF preview is ready. Opening external viewer can be added next.',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  BorderRadius _buildBubbleRadius() {
    if (isUser) {
      return BorderRadius.only(
        topLeft: const Radius.circular(AppRadius.lg),
        topRight: Radius.circular(
          isGroupedWithPrevious ? AppRadius.md : AppRadius.lg,
        ),
        bottomLeft: const Radius.circular(AppRadius.lg),
        bottomRight: Radius.circular(
          isGroupedWithNext ? AppRadius.md : AppRadius.lg,
        ),
      );
    }

    return BorderRadius.only(
      topLeft: Radius.circular(
        isGroupedWithPrevious ? AppRadius.md : AppRadius.lg,
      ),
      topRight: const Radius.circular(AppRadius.lg),
      bottomLeft: Radius.circular(
        isGroupedWithNext ? AppRadius.md : AppRadius.lg,
      ),
      bottomRight: const Radius.circular(AppRadius.lg),
    );
  }
}

class _TypingDots extends StatefulWidget {
  final Color color;

  const _TypingDots({required this.color});

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 920),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _dotOpacity(int index) {
    final phase = (_controller.value * math.pi * 2) - (index * 0.72);
    final normalized = (math.sin(phase) + 1) / 2;
    return 0.25 + (normalized * 0.75);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.only(right: index == 2 ? 0 : AppSpacing.xs),
              child: Opacity(
                opacity: _dotOpacity(index),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  final Color color;

  const _BlinkingCursor({required this.color});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    )..repeat(reverse: true);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Text(
        '|',
        style: AppTextStyles.bodyMedium.copyWith(
          color: widget.color,
          height: 1.5,
        ),
      ),
    );
  }
}
