import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_icon_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';

/// Bottom chat input bar with expandable multiline support
/// Contains: + button, text field, mic, send, and expand button
class ChatInputBar extends StatefulWidget {
  final Function(String) onSendMessage;

  const ChatInputBar({
    super.key,
    required this.onSendMessage,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Sends the message and clears input
  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSendMessage(text);
    _controller.clear();
    
    // Collapse if expanded
    if (_isExpanded) {
      setState(() {
        _isExpanded = false;
      });
    }
  }

  /// Toggles expanded/collapsed state with smooth animation
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    // Focus text field when expanding
    if (_isExpanded) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.background : AppColorsLight.background,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColorsDark.border : AppColorsLight.border,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Main input container (rounded border)
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  constraints: BoxConstraints(
                    minHeight: 48,
                    maxHeight: _isExpanded ? 120 : 48,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColorsDark.background : AppColorsLight.background,
                    border: Border.all(
                      color: isDark ? AppColorsDark.border : AppColorsLight.border,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Plus button (attachments)
                      AppIconButton(
                        icon: Icons.add,
                        onPressed: () {
                          // Placeholder for attachments
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Attachments coming soon'),
                            ),
                          );
                        },
                      ),

                      // Text input field
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          maxLines: _isExpanded ? 4 : 1,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          style: AppTextStyles.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'Ask Anything',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColorsDark.secondaryText
                                  : AppColorsLight.secondaryText,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.md,
                            ),
                          ),
                        ),
                      ),

                      // Mic button (voice input)
                      AppIconButton(
                        icon: Icons.mic_none,
                        onPressed: () {
                          // Placeholder for voice input
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Voice input coming soon'),
                            ),
                          );
                        },
                      ),

                      // Send button (only show when has text)
                      if (_hasText)
                        AppIconButton(
                          icon: Icons.send,
                          onPressed: _sendMessage,
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Expand button (outside the input container)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? AppColorsDark.background : AppColorsLight.background,
                  border: Border.all(
                    color: isDark ? AppColorsDark.border : AppColorsLight.border,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                    color: isDark ? AppColorsDark.primaryText : AppColorsLight.primaryText,
                  ),
                  onPressed: _toggleExpanded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
