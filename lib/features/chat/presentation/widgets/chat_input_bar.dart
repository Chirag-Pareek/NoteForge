import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_effects.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/chat_compose_draft_store.dart';
import '../../domain/compose_attachment.dart';
import 'chat_compose_editor.dart';

/// Minimal launcher bar for compose flow.
/// Tapping the input field or expand icon opens full-screen AI compose editor.
class ChatInputBar extends StatefulWidget {
  final SendComposeMessage onSendMessage;
  final TextEditingController? controller;
  final bool autoFocusOnInit;

  const ChatInputBar({
    super.key,
    required this.onSendMessage,
    this.controller,
    this.autoFocusOnInit = false,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  static const _draftWriteDebounce = Duration(milliseconds: 300);
  static const Set<String> _imageExtensions = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'bmp',
  };

  late final TextEditingController _controller;
  late final bool _ownsController;
  final ChatComposeDraftStore _draftStore = ChatComposeDraftStore();
  Timer? _draftSaveDebounceTimer;

  List<ComposeAttachment> _attachments = [];
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.trim().isNotEmpty;
    _controller.addListener(_handleTextChange);
    _restoreDraft();

    if (widget.autoFocusOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _openComposeEditor();
      });
    }
  }

  @override
  void dispose() {
    _draftSaveDebounceTimer?.cancel();
    _controller.removeListener(_handleTextChange);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleTextChange() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    _scheduleDraftSave();
  }

  Future<void> _restoreDraft() async {
    final draft = await _draftStore.loadDraft();
    if (!mounted) {
      return;
    }

    // Preserve prefilled text (e.g. action cards) if already present.
    if (_controller.text.trim().isNotEmpty) {
      return;
    }

    if (draft.text.isEmpty && draft.attachments.isEmpty) {
      return;
    }

    _controller.value = TextEditingValue(
      text: draft.text,
      selection: TextSelection.collapsed(offset: draft.text.length),
    );

    setState(() {
      _attachments = draft.attachments;
      _hasText = _controller.text.trim().isNotEmpty;
    });
  }

  void _scheduleDraftSave() {
    _draftSaveDebounceTimer?.cancel();
    _draftSaveDebounceTimer = Timer(_draftWriteDebounce, _persistDraft);
  }

  Future<void> _persistDraft() async {
    await _draftStore.saveDraft(
      text: _controller.text,
      attachments: _attachments,
    );
  }

  Future<void> _clearDraft() async {
    await _draftStore.clearDraft();
  }

  void _setAttachments(List<ComposeAttachment> attachments) {
    setState(() {
      _attachments = attachments;
    });
    _scheduleDraftSave();
  }

  Future<List<ComposeAttachment>> _pickAttachments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const [
        'jpg',
        'jpeg',
        'png',
        'webp',
        'gif',
        'bmp',
        'pdf',
      ],
    );

    if (result == null) {
      return const <ComposeAttachment>[];
    }

    return result.files
        .where((file) => file.path != null && file.path!.trim().isNotEmpty)
        .map(ComposeAttachment.fromPlatformFile)
        .toList();
  }

  Future<bool> _sendMessage(
    String text,
    List<ComposeAttachment> attachments,
  ) async {
    final success = await widget.onSendMessage(text, attachments);
    if (!success) {
      return false;
    }

    _controller.clear();
    _setAttachments(const <ComposeAttachment>[]);
    await _clearDraft();
    return true;
  }

  Future<void> _openComposeEditor({bool autoStartListening = false}) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Compose Editor',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, _, _) {
        return ChatComposeEditor(
          controller: _controller,
          initialAttachments: _attachments,
          onAttachmentsChanged: _setAttachments,
          onPickAttachments: _pickAttachments,
          onSendMessage: _sendMessage,
          autoStartListening: autoStartListening,
        );
      },
      transitionBuilder: (context, animation, _, child) {
        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
    );
  }

  Future<void> _openComposeEditorWithMic() async {
    await HapticFeedback.lightImpact();
    await _openComposeEditor(autoStartListening: true);
  }

  void _removeAttachment(String id) {
    _setAttachments(_attachments.where((item) => item.id != id).toList());
  }

  bool _isImageAttachment(ComposeAttachment attachment) {
    return _imageExtensions.contains(attachment.extension.toLowerCase());
  }

  IconData _fileIcon(String extension) {
    const pdfExt = {'pdf'};
    const docExt = {'doc', 'docx', 'txt'};
    const sheetExt = {'xls', 'xlsx'};
    const slideExt = {'ppt', 'pptx'};

    if (pdfExt.contains(extension)) return Icons.picture_as_pdf_outlined;
    if (docExt.contains(extension)) return Icons.description_outlined;
    if (sheetExt.contains(extension)) return Icons.table_chart_outlined;
    if (slideExt.contains(extension)) return Icons.slideshow_outlined;
    return Icons.attach_file;
  }

  Widget _buildAttachmentThumb(ComposeAttachment attachment, bool isDark) {
    if (_isImageAttachment(attachment)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Image.file(
          File(attachment.path),
          width: 24,
          height: 24,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildAttachmentFallback(attachment, isDark),
        ),
      );
    }

    return _buildAttachmentFallback(attachment, isDark);
  }

  Widget _buildAttachmentFallback(ComposeAttachment attachment, bool isDark) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        color: isDark
            ? AppColorsDark.lightBackground
            : AppColorsLight.lightBackground,
        border: Border.all(
          color: isDark ? AppColorsDark.border : AppColorsLight.border,
        ),
      ),
      child: Icon(
        _fileIcon(attachment.extension.toLowerCase()),
        size: 14,
        color: isDark
            ? AppColorsDark.secondaryText
            : AppColorsLight.secondaryText,
      ),
    );
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 560;
            final previewLines = _attachments.isEmpty ? 1 : 2;

            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        onTap: _openComposeEditor,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          constraints: const BoxConstraints(minHeight: 48),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColorsDark.background
                                : AppColorsLight.background,
                            border: Border.all(
                              color: isDark
                                  ? AppColorsDark.border
                                  : AppColorsLight.border,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            boxShadow: AppEffects.subtleDepth(
                              Theme.of(context).brightness,
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_attachments.isNotEmpty)
                                SizedBox(
                                  height: 36,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: _attachments.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(width: AppSpacing.sm),
                                    itemBuilder: (context, index) {
                                      final attachment = _attachments[index];
                                      return Container(
                                        constraints: BoxConstraints(
                                          maxWidth: isWide ? 200 : 150,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: AppSpacing.xs,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.sm,
                                          ),
                                          border: Border.all(
                                            color: isDark
                                                ? AppColorsDark.border
                                                : AppColorsLight.border,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildAttachmentThumb(
                                              attachment,
                                              isDark,
                                            ),
                                            const SizedBox(
                                              width: AppSpacing.xs,
                                            ),
                                            Flexible(
                                              child: Text(
                                                attachment.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTextStyles.label,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: AppSpacing.xs,
                                            ),
                                            InkWell(
                                              onTap: () => _removeAttachment(
                                                attachment.id,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppRadius.full,
                                                  ),
                                              child: Icon(
                                                Icons.close,
                                                size: 14,
                                                color: isDark
                                                    ? AppColorsDark
                                                          .secondaryText
                                                    : AppColorsLight
                                                          .secondaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              if (_attachments.isNotEmpty)
                                const SizedBox(height: AppSpacing.xs),
                              Text(
                                _hasText ? _controller.text : 'Ask Anything',
                                maxLines: previewLines,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: _hasText
                                      ? (isDark
                                            ? AppColorsDark.primaryText
                                            : AppColorsLight.primaryText)
                                      : (isDark
                                            ? AppColorsDark.secondaryText
                                            : AppColorsLight.secondaryText),
                                ),
                              ),
                              if (_attachments.isNotEmpty && !_hasText)
                                Text(
                                  '${_attachments.length} attachment${_attachments.length == 1 ? '' : 's'} - tap to compose',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.label.copyWith(
                                    color: isDark
                                        ? AppColorsDark.secondaryText
                                        : AppColorsLight.secondaryText,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColorsDark.background
                          : AppColorsLight.background,
                      border: Border.all(
                        color: isDark
                            ? AppColorsDark.border
                            : AppColorsLight.border,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: AppEffects.subtleDepth(
                        Theme.of(context).brightness,
                      ),
                    ),
                    child: IconButton(
                      onPressed: _openComposeEditorWithMic,
                      tooltip: 'Voice prompt',
                      icon: Icon(
                        Icons.mic_none,
                        color: isDark
                            ? AppColorsDark.primaryText
                            : AppColorsLight.primaryText,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColorsDark.background
                          : AppColorsLight.background,
                      border: Border.all(
                        color: isDark
                            ? AppColorsDark.border
                            : AppColorsLight.border,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: AppEffects.subtleDepth(
                        Theme.of(context).brightness,
                      ),
                    ),
                    child: IconButton(
                      onPressed: _openComposeEditor,
                      icon: Icon(
                        Icons.open_in_full,
                        color: isDark
                            ? AppColorsDark.primaryText
                            : AppColorsLight.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
