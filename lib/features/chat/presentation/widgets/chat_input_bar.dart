import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_icon_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;
  final VoidCallback onAttach;
  final VoidCallback onMic;

  const ChatInputBar({
    super.key,
    required this.onSend,
    required this.onAttach,
    required this.onMic,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();

  // Expand/collapse logic for the input bar.
  bool _isExpanded = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                if (_isExpanded)
                  AppIconButton(
                    icon: Icons.add,
                    onPressed: widget.onAttach,
                    tooltip: 'Attach',
                  ),
                Expanded(
                  child: AppTextField(
                    hintText: 'Ask Anything',
                    controller: _controller,
                    maxLines: _isExpanded ? 4 : 1,
                  ),
                ),
                if (_isExpanded)
                  AppIconButton(
                    icon: Icons.mic_none,
                    onPressed: widget.onMic,
                    tooltip: 'Mic',
                  ),
                AppIconButton(
                  icon: Icons.send_outlined,
                  onPressed: _send,
                  tooltip: 'Send',
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        AppIconButton(
          icon: _isExpanded ? Icons.expand_less : Icons.expand_more,
          onPressed: _toggleExpanded,
          tooltip: 'Expand',
        ),
      ],
    );
  }
}
