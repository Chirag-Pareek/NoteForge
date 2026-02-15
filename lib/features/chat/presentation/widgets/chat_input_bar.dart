import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
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
        'pdf',
        'doc',
        'docx',
        'ppt',
        'pptx',
        'xls',
        'xlsx',
        'txt',
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

  Future<void> _openComposeEditor() async {
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
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    onTap: _openComposeEditor,
                    child: Container(
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
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Text(
                        _hasText ? _controller.text : 'Ask Anything',
                        maxLines: 1,
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
        ),
      ),
    );
  }
}
