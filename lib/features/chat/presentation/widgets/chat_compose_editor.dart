import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_effects.dart';
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
  final bool autoStartListening;

  const ChatComposeEditor({
    super.key,
    required this.controller,
    required this.initialAttachments,
    required this.onAttachmentsChanged,
    required this.onPickAttachments,
    required this.onSendMessage,
    this.autoStartListening = false,
  });

  @override
  State<ChatComposeEditor> createState() => _ChatComposeEditorState();
}

class _ChatComposeEditorState extends State<ChatComposeEditor> {
  static const Set<String> _imageExtensions = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'bmp',
  };

  late List<ComposeAttachment> _attachments;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _textScrollController = ScrollController();
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  bool _isSending = false;
  bool _hasText = false;
  bool _speechAvailable = false;
  bool _hasMicPermission = false;
  bool _isRequestingMicPermission = false;
  bool _micPermissionDenied = false;
  bool _isListening = false;
  String _speechSeedText = '';
  double _soundLevel = 0.08;
  double _minSoundLevel = 50000;
  double _maxSoundLevel = -50000;

  bool get _canSend => !_isSending && (_hasText || _attachments.isNotEmpty);

  @override
  void initState() {
    super.initState();
    _attachments = List<ComposeAttachment>.from(widget.initialAttachments);
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onTextChanged);
    _bootstrapSpeech();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _focusNode.requestFocus();
      widget.controller.selection = TextSelection.collapsed(
        offset: widget.controller.text.length,
      );
      if (widget.autoStartListening) {
        _startListening();
      }
    });
  }

  @override
  void dispose() {
    _speechToText.cancel();
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    _textScrollController.dispose();
    super.dispose();
  }

  Future<void> _bootstrapSpeech() async {
    final hasPermission = await _speechToText.hasPermission;
    var available = false;
    if (hasPermission) {
      available = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _speechAvailable = available;
      _hasMicPermission = hasPermission;
      _micPermissionDenied = false;
    });
  }

  void _onSpeechStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      if (!mounted || !_isListening) {
        return;
      }
      setState(() {
        _isListening = false;
        _soundLevel = 0.08;
      });
    }
  }

  void _onSpeechError(dynamic error) {
    if (!mounted) {
      return;
    }
    final details = error.toString().toLowerCase();
    final isPermissionError = details.contains('permission');

    setState(() {
      _isListening = false;
      _soundLevel = 0.08;
      if (isPermissionError) {
        _hasMicPermission = false;
        _micPermissionDenied = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isPermissionError
              ? 'Microphone permission denied. Enable it in app settings.'
              : 'Speech recognition error. Please try again.',
        ),
      ),
    );
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
    await HapticFeedback.lightImpact();
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

  bool get _isMicDisabled {
    if (_isSending || _isRequestingMicPermission) {
      return true;
    }
    return _micPermissionDenied && !_hasMicPermission;
  }

  Future<bool> _requestMicPermissionAndInitialize() async {
    if (_isRequestingMicPermission) {
      return false;
    }
    setState(() {
      _isRequestingMicPermission = true;
    });

    final available = await _speechToText.initialize(
      onStatus: _onSpeechStatus,
      onError: _onSpeechError,
    );
    final hasPermission = await _speechToText.hasPermission;

    if (!mounted) {
      return false;
    }

    setState(() {
      _isRequestingMicPermission = false;
      _speechAvailable = available;
      _hasMicPermission = hasPermission;
      _micPermissionDenied = !hasPermission;
    });

    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission is required for voice typing.'),
        ),
      );
      return false;
    }

    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition is unavailable on this device.'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _toggleListening() async {
    if (_isMicDisabled) {
      return;
    }
    if (_isListening) {
      await HapticFeedback.selectionClick();
      await _stopListening(clearPartialText: false);
      return;
    }
    await HapticFeedback.lightImpact();
    await _startListening();
  }

  Future<void> _startListening() async {
    if (_isMicDisabled || _isListening) {
      return;
    }

    if (!_hasMicPermission || !_speechAvailable) {
      final isReady = await _requestMicPermissionAndInitialize();
      if (!isReady) {
        return;
      }
    }

    if (!_speechAvailable || !_hasMicPermission) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition is unavailable')),
      );
      return;
    }

    _speechSeedText = widget.controller.text.trimRight();
    _minSoundLevel = 50000;
    _maxSoundLevel = -50000;
    setState(() {
      _isListening = true;
      _soundLevel = 0.12;
    });

    await _speechToText.listen(
      onResult: (result) {
        final recognized = result.recognizedWords.trim();
        final combined = _speechSeedText.isEmpty
            ? recognized
            : recognized.isEmpty
            ? _speechSeedText
            : '$_speechSeedText $recognized';

        widget.controller.value = TextEditingValue(
          text: combined,
          selection: TextSelection.collapsed(offset: combined.length),
        );
      },
      onSoundLevelChange: _onSoundLevelChange,
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        listenMode: stt.ListenMode.dictation,
        cancelOnError: false,
      ),
    );
  }

  void _onSoundLevelChange(double level) {
    if (!mounted) {
      return;
    }
    _minSoundLevel = math.min(_minSoundLevel, level);
    _maxSoundLevel = math.max(_maxSoundLevel, level);
    final dynamicRange = _maxSoundLevel - _minSoundLevel;
    final normalizedLevel = dynamicRange <= 0.01
        ? 0.08
        : ((level - _minSoundLevel) / dynamicRange).clamp(0.0, 1.0);
    if ((normalizedLevel - _soundLevel).abs() < 0.03) {
      return;
    }
    setState(() {
      _soundLevel = normalizedLevel;
    });
  }

  Future<void> _stopListening({required bool clearPartialText}) async {
    if (!_isListening) {
      return;
    }
    if (clearPartialText) {
      await _speechToText.cancel();
    } else {
      await _speechToText.stop();
    }
    if (!mounted) {
      return;
    }
    if (clearPartialText) {
      widget.controller.value = TextEditingValue(
        text: _speechSeedText,
        selection: TextSelection.collapsed(offset: _speechSeedText.length),
      );
    }
    setState(() {
      _isListening = false;
      _soundLevel = 0.08;
    });
  }

  Future<void> _cancelListeningAndClear() async {
    await HapticFeedback.mediumImpact();
    await _stopListening(clearPartialText: true);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Voice input cancelled')));
  }

  void _removeAttachment(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      _attachments = _attachments.where((file) => file.id != id).toList();
    });
    _syncAttachments();
  }

  void _clearText() {
    widget.controller.clear();
  }

  Future<void> _sendMessage() async {
    if (!_canSend) {
      return;
    }
    await HapticFeedback.lightImpact();

    if (_isListening) {
      await _stopListening(clearPartialText: false);
    }

    setState(() {
      _isSending = true;
    });

    final success = await widget.onSendMessage(
      widget.controller.text.trim(),
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

  void _insertBulletPoints() {
    _transformSelectedLines((lines) {
      return lines
          .map((line) {
            final trimmed = line.trimLeft();
            if (trimmed.isEmpty || trimmed.startsWith('- ')) {
              return line;
            }
            return line.replaceFirst(trimmed, '- $trimmed');
          })
          .toList(growable: false);
    });
  }

  void _insertNumberedList() {
    _transformSelectedLines((lines) {
      var number = 1;
      return lines
          .map((line) {
            final trimmed = line.trimLeft();
            if (trimmed.isEmpty || RegExp(r'^\d+\.\s').hasMatch(trimmed)) {
              return line;
            }
            return line.replaceFirst(trimmed, '${number++}. $trimmed');
          })
          .toList(growable: false);
    });
  }

  void _clearFormatting() {
    _transformSelectedLines((lines) {
      return lines
          .map((line) {
            final trimmed = line.trimLeft();
            final withoutBullet = trimmed.replaceFirst(RegExp(r'^-\s+'), '');
            final withoutNumber = withoutBullet.replaceFirst(
              RegExp(r'^\d+\.\s+'),
              '',
            );
            return line.replaceFirst(trimmed, withoutNumber);
          })
          .toList(growable: false);
    });
  }

  void _insertTemplate(String label) {
    const templates = <String, String>{
      'Explain':
          'Explain this topic in simple steps with one real-world example.',
      'Summarize':
          'Summarize this into concise revision notes with key takeaways.',
      'Practice':
          'Create 5 practice questions with answers and short explanations.',
    };
    final text = templates[label];
    if (text == null) {
      return;
    }
    _insertAtCursor(text);
  }

  void _insertAtCursor(String value) {
    final existingText = widget.controller.text;
    final selection = widget.controller.selection;

    final start = selection.isValid ? selection.start : existingText.length;
    final end = selection.isValid ? selection.end : existingText.length;
    final replacement = existingText.replaceRange(start, end, value);
    final offset = start + value.length;
    widget.controller.value = TextEditingValue(
      text: replacement,
      selection: TextSelection.collapsed(offset: offset),
    );
    _focusNode.requestFocus();
  }

  void _transformSelectedLines(
    List<String> Function(List<String> lines) transform,
  ) {
    final text = widget.controller.text;
    if (text.isEmpty) {
      return;
    }
    final selection = widget.controller.selection;
    final start = selection.isValid ? selection.start : 0;
    final end = selection.isValid ? selection.end : text.length;

    final selectedStart = start < end ? start : end;
    final selectedEnd = start < end ? end : start;

    final lineStart = text.lastIndexOf('\n', selectedStart - 1) + 1;
    final lineEndIndex = text.indexOf('\n', selectedEnd);
    final lineEnd = lineEndIndex == -1 ? text.length : lineEndIndex;

    final selectedBlock = text.substring(lineStart, lineEnd);
    final lines = selectedBlock.split('\n');
    final transformed = transform(lines).join('\n');

    final updated = text.replaceRange(lineStart, lineEnd, transformed);
    final cursorOffset = lineStart + transformed.length;
    widget.controller.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
    _focusNode.requestFocus();
  }

  int _wordCount(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return 0;
    }
    return normalized.split(RegExp(r'\s+')).length;
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

  bool _isImageAttachment(ComposeAttachment attachment) {
    return _imageExtensions.contains(attachment.extension.toLowerCase());
  }

  bool _isPdfAttachment(ComposeAttachment attachment) {
    return attachment.extension.toLowerCase() == 'pdf';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColorsDark.background : AppColorsLight.background,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth > 900
                ? AppSpacing.xxl
                : AppSpacing.lg;
            return Column(
              children: [
                _buildTopBar(isDark),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      AppSpacing.lg,
                      horizontalPadding,
                      AppSpacing.md,
                    ),
                    child: _buildEditorArea(isDark),
                  ),
                ),
                _buildBottomBar(isDark),
              ],
            );
          },
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
          Text('Compose', style: AppTextStyles.bodyLarge),
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

  Widget _buildEditorArea(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.background : AppColorsLight.background,
        border: Border.all(
          color: isDark ? AppColorsDark.border : AppColorsLight.border,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppEffects.subtleDepth(Theme.of(context).brightness),
      ),
      child: Column(
        children: [
          _buildWritingToolbar(isDark),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: _attachments.isEmpty
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      Divider(
                        height: 1,
                        color: isDark
                            ? AppColorsDark.border
                            : AppColorsLight.border,
                      ),
                      _buildAttachmentPreviewInsideInput(isDark),
                    ],
                  ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColorsDark.border : AppColorsLight.border,
          ),
          Expanded(
            child: Scrollbar(
              controller: _textScrollController,
              thumbVisibility: true,
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
                textCapitalization: TextCapitalization.sentences,
                cursorColor: isDark
                    ? AppColorsDark.primaryText
                    : AppColorsLight.primaryText,
                scrollPadding: const EdgeInsets.only(bottom: 160),
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: _isListening
                      ? 'Listening...'
                      : 'Write your prompt...',
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
          ),
        ],
      ),
    );
  }

  Widget _buildWritingToolbar(bool isDark) {
    final iconColor = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;
    return SizedBox(
      height: 54,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        physics: const BouncingScrollPhysics(),
        children: [
          IconButton(
            onPressed: _insertBulletPoints,
            icon: const Icon(Icons.format_list_bulleted),
            tooltip: 'Bullet points',
            splashRadius: AppSpacing.xl,
            color: iconColor,
          ),
          IconButton(
            onPressed: _insertNumberedList,
            icon: const Icon(Icons.format_list_numbered),
            tooltip: 'Numbered list',
            splashRadius: AppSpacing.xl,
            color: iconColor,
          ),
          IconButton(
            onPressed: _clearFormatting,
            icon: const Icon(Icons.format_clear),
            tooltip: 'Clear formatting',
            splashRadius: AppSpacing.xl,
            color: iconColor,
          ),
          const SizedBox(width: AppSpacing.sm),
          _templateButton('Explain', isDark),
          const SizedBox(width: AppSpacing.sm),
          _templateButton('Summarize', isDark),
          const SizedBox(width: AppSpacing.sm),
          _templateButton('Practice', isDark),
        ],
      ),
    );
  }

  Widget _templateButton(String label, bool isDark) {
    return TextButton(
      onPressed: () => _insertTemplate(label),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        foregroundColor: isDark
            ? AppColorsDark.secondaryText
            : AppColorsLight.secondaryText,
      ),
      child: Text(label, style: AppTextStyles.bodySmall),
    );
  }

  Widget _buildAttachmentPreviewInsideInput(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: _attachments
            .map((attachment) => _buildAttachmentChip(attachment, isDark))
            .toList(growable: false),
      ),
    );
  }

  Widget _buildAttachmentChip(ComposeAttachment attachment, bool isDark) {
    if (_isImageAttachment(attachment)) {
      return _buildImageChip(attachment, isDark);
    }
    if (_isPdfAttachment(attachment)) {
      return _buildPdfChip(attachment, isDark);
    }
    return _buildPdfChip(attachment, isDark);
  }

  Widget _buildImageChip(ComposeAttachment attachment, bool isDark) {
    return Container(
      width: 124,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.background : AppColorsLight.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: isDark ? AppColorsDark.border : AppColorsLight.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Image.file(
                  File(attachment.path),
                  width: double.infinity,
                  height: 78,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 78,
                    color: isDark
                        ? AppColorsDark.lightBackground
                        : AppColorsLight.lightBackground,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: isDark
                          ? AppColorsDark.secondaryText
                          : AppColorsLight.secondaryText,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: InkWell(
                  onTap: () => _removeAttachment(attachment.id),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColorsDark.background
                          : AppColorsLight.background,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 12,
                      color: isDark
                          ? AppColorsDark.secondaryText
                          : AppColorsLight.secondaryText,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            attachment.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label,
          ),
        ],
      ),
    );
  }

  Widget _buildPdfChip(ComposeAttachment attachment, bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.background : AppColorsLight.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: isDark ? AppColorsDark.border : AppColorsLight.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall,
                ),
                Text(
                  _formatSize(attachment.sizeBytes),
                  style: AppTextStyles.label.copyWith(
                    color: isDark
                        ? AppColorsDark.secondaryText
                        : AppColorsLight.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          InkWell(
            onTap: () => _removeAttachment(attachment.id),
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: Icon(
                Icons.close,
                size: 14,
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

  Widget _buildBottomBar(bool isDark) {
    final wordCount = _wordCount(widget.controller.text);
    final canSend = _canSend;
    final primaryText = isDark
        ? AppColorsDark.primaryText
        : AppColorsLight.primaryText;
    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.background : AppColorsLight.background,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColorsDark.border : AppColorsLight.border,
          ),
        ),
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _isListening
                ? Row(
                    key: const ValueKey<String>('listening-mic'),
                    children: [
                      Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColorsDark.lightBackground
                              : AppColorsLight.lightBackground,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.mic_rounded,
                              size: 18,
                              color: primaryText,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            _ListeningWaveform(
                              soundLevel: _soundLevel,
                              color: primaryText,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      TextButton(
                        onPressed: _cancelListeningAndClear,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          minimumSize: const Size(0, 32),
                          foregroundColor: secondaryText,
                        ),
                        child: const Text('Cancel'),
                      ),
                    ],
                  )
                : IconButton(
                    key: const ValueKey<String>('idle-mic'),
                    onPressed: _isMicDisabled ? null : _toggleListening,
                    splashRadius: AppSpacing.xl,
                    tooltip: _micPermissionDenied
                        ? 'Microphone permission denied'
                        : _isRequestingMicPermission
                        ? 'Requesting microphone permission'
                        : 'Start voice typing',
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 170),
                      child: _isRequestingMicPermission
                          ? SizedBox(
                              key: const ValueKey<String>('mic-loading'),
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  secondaryText,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.mic_none,
                              key: const ValueKey<String>('mic-idle-icon'),
                              color: _isMicDisabled
                                  ? secondaryText
                                  : primaryText,
                            ),
                    ),
                  ),
          ),
          AppIconButton(icon: Icons.attach_file, onPressed: _pickAttachments),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _isListening
                  ? 'Listening... tap mic to stop'
                  : _micPermissionDenied
                  ? 'Microphone unavailable'
                  : '$wordCount words',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(color: secondaryText),
            ),
          ),
          AnimatedScale(
            scale: canSend ? 1 : 0.97,
            duration: const Duration(milliseconds: 140),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColorsDark.lightBackground
                    : AppColorsLight.lightBackground,
                border: Border.all(
                  color: isDark ? AppColorsDark.border : AppColorsLight.border,
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: AppEffects.subtleDepth(Theme.of(context).brightness),
              ),
              child: IconButton(
                onPressed: canSend ? _sendMessage : null,
                splashRadius: AppSpacing.xl,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: _isSending
                      ? const SizedBox(
                          key: ValueKey<String>('loading'),
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.arrow_upward_rounded,
                          key: const ValueKey<String>('send'),
                          color: canSend
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
        ],
      ),
    );
  }
}

class _ListeningWaveform extends StatefulWidget {
  final double soundLevel;
  final Color color;

  const _ListeningWaveform({required this.soundLevel, required this.color});

  @override
  State<_ListeningWaveform> createState() => _ListeningWaveformState();
}

class _ListeningWaveformState extends State<_ListeningWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _barHeight(int index) {
    final levelBoost = 6 + (widget.soundLevel * 13);
    final phase = (_controller.value * math.pi * 2) + (index * 0.85);
    final oscillation = ((math.sin(phase) + 1) / 2) * 7;
    return (levelBoost + oscillation).clamp(5.0, 20.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(4, (index) {
            return Padding(
              padding: EdgeInsets.only(right: index == 3 ? 0 : AppSpacing.xs),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                width: 3,
                height: _barHeight(index),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
