import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon_button.dart';
import '../../domain/compose_attachment.dart';

typedef SendComposeMessage =
    Future<bool> Function(String text, List<ComposeAttachment> attachments);

class ChatComposeEditor extends StatefulWidget {
  final TextEditingController controller;
  final List<ComposeAttachment> initialAttachments;
  final ValueChanged<List<ComposeAttachment>> onAttachmentsChanged;
  final Future<List<ComposeAttachment>> Function() onPickAttachments;
  final SendComposeMessage onSendMessage;

  const ChatComposeEditor({
    super.key,
    required this.controller,
    required this.initialAttachments,
    required this.onAttachmentsChanged,
    required this.onPickAttachments,
    required this.onSendMessage,
  });

  @override
  State<ChatComposeEditor> createState() => _ChatComposeEditorState();
}

class _ChatComposeEditorState extends State<ChatComposeEditor> {
  late List<ComposeAttachment> _attachments;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _textScrollController = ScrollController();
  bool _isSending = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _attachments = List<ComposeAttachment>.from(widget.initialAttachments);
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onTextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _focusNode.requestFocus();
      widget.controller.selection = TextSelection.collapsed(
        offset: widget.controller.text.length,
      );
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    _textScrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _syncAttachments() {
    widget.onAttachmentsChanged(List<ComposeAttachment>.from(_attachments));
  }

  Future<void> _pickAttachments() async {
    final picked = await widget.onPickAttachments();
    if (picked.isEmpty) {
      return;
    }

    final mergedById = <String, ComposeAttachment>{
      for (final attachment in _attachments) attachment.id: attachment,
    };
    for (final attachment in picked) {
      mergedById[attachment.id] = attachment;
    }

    setState(() {
      _attachments = mergedById.values.toList();
    });
    _syncAttachments();
  }

  void _removeAttachment(String id) {
    setState(() {
      _attachments = _attachments.where((file) => file.id != id).toList();
    });
    _syncAttachments();
  }

  void _clearText() {
    widget.controller.clear();
  }

  Future<void> _sendMessage() async {
    final text = widget.controller.text.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    final success = await widget.onSendMessage(
      text,
      List<ComposeAttachment>.from(_attachments),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSending = false;
      if (success) {
        _attachments = const <ComposeAttachment>[];
      }
    });

    if (success) {
      Navigator.of(context).pop();
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  IconData _fileIcon(String extension) {
    const imageExt = {'jpg', 'jpeg', 'png', 'gif', 'webp'};
    const pdfExt = {'pdf'};
    const docExt = {'doc', 'docx', 'txt'};
    const sheetExt = {'xls', 'xlsx'};
    const slideExt = {'ppt', 'pptx'};

    if (imageExt.contains(extension)) return Icons.image_outlined;
    if (pdfExt.contains(extension)) return Icons.picture_as_pdf_outlined;
    if (docExt.contains(extension)) return Icons.description_outlined;
    if (sheetExt.contains(extension)) return Icons.table_chart_outlined;
    if (slideExt.contains(extension)) return Icons.slideshow_outlined;
    return Icons.attach_file;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColorsDark.background : AppColorsLight.background,
      child: SafeArea(
        child: Column(
          children: [
            _buildTopBar(isDark),
            if (_attachments.isNotEmpty) _buildAttachmentPreview(isDark),
            _buildEditorArea(isDark),
            _buildBottomBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColorsDark.border : AppColorsLight.border,
          ),
        ),
      ),
      child: Row(
        children: [
          AppIconButton(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          TextButton(
            onPressed: _clearText,
            child: Text(
              'Clear',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColorsDark.secondaryText
                    : AppColorsLight.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentPreview(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: _attachments.map((attachment) {
          return InputChip(
            avatar: Icon(
              _fileIcon(attachment.extension),
              size: 18,
              color: isDark
                  ? AppColorsDark.secondaryText
                  : AppColorsLight.secondaryText,
            ),
            label: SizedBox(
              width: 180,
              child: Text(
                '${attachment.name} (${_formatSize(attachment.sizeBytes)})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            onDeleted: () => _removeAttachment(attachment.id),
            deleteIconColor: isDark
                ? AppColorsDark.secondaryText
                : AppColorsLight.secondaryText,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEditorArea(bool isDark) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.background : AppColorsLight.background,
          border: Border.all(
            color: isDark ? AppColorsDark.border : AppColorsLight.border,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          expands: true,
          minLines: null,
          maxLines: null,
          scrollController: _textScrollController,
          scrollPhysics: const BouncingScrollPhysics(),
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Write your prompt...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColorsDark.secondaryText
                  : AppColorsLight.secondaryText,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(AppSpacing.lg),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColorsDark.border : AppColorsLight.border,
          ),
        ),
      ),
      child: Row(
        children: [
          AppIconButton(icon: Icons.attach_file, onPressed: _pickAttachments),
          AppIconButton(
            icon: Icons.mic_none,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voice input coming soon')),
              );
            },
          ),
          const Spacer(),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? AppColorsDark.border : AppColorsLight.border,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: IconButton(
              onPressed: _hasText && !_isSending ? _sendMessage : null,
              icon: _isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.send,
                      color: _hasText
                          ? (isDark
                                ? AppColorsDark.primaryText
                                : AppColorsLight.primaryText)
                          : (isDark
                                ? AppColorsDark.secondaryText
                                : AppColorsLight.secondaryText),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
