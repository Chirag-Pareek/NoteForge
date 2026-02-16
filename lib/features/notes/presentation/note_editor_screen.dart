import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_effects.dart';
import '../../../core/theme/app_radius.dart';
import 'controllers/notes_controller.dart';

/// Full-screen note editor with auto-save and AI assist.
class NoteEditorScreen extends StatefulWidget {
  final String noteId;
  final String initialTitle;
  final String initialContent;
  final String topicId;
  final String chapterId;
  final String subjectId;

  const NoteEditorScreen({
    super.key,
    required this.noteId,
    required this.initialTitle,
    required this.initialContent,
    required this.topicId,
    required this.chapterId,
    required this.subjectId,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = context.read<NotesController>();
      ctrl.startEditing(
        widget.noteId,
        widget.initialTitle,
        widget.initialContent,
      );
    });

    _titleController.addListener(_onChanged);
    _contentController.addListener(_onChanged);
  }

  void _onChanged() {
    context.read<NotesController>().onEditorChanged(
      _titleController.text,
      _contentController.text,
    );
  }

  @override
  void dispose() {
    _titleController.removeListener(_onChanged);
    _contentController.removeListener(_onChanged);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final ctrl = context.read<NotesController>();
    await ctrl.saveNow();
    ctrl.stopEditing();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final canPop = await _onWillPop();
        if (canPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: Consumer<NotesController>(
            builder: (context, ctrl, _) {
              if (ctrl.isSaving) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: secondaryText,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Saving...',
                      style: AppTextStyles.label.copyWith(color: secondaryText),
                    ),
                  ],
                );
              }
              if (ctrl.hasPendingChanges) {
                return Text(
                  'Edited',
                  style: AppTextStyles.label.copyWith(color: secondaryText),
                );
              }
              return Text(
                'Saved',
                style: AppTextStyles.label.copyWith(color: secondaryText),
              );
            },
          ),
          actions: [
            // AI Assist button
            IconButton(
              icon: const Icon(Icons.auto_awesome_outlined),
              tooltip: 'AI Assist',
              onPressed: () => _showAiAssist(context),
            ),
            // Save button
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Save & Close',
              onPressed: () async {
                final ctrl = context.read<NotesController>();
                await ctrl.saveNow(markAsFinal: true);
                ctrl.stopEditing();
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final horizontalPadding = AppBreakpoints.pageHorizontalPadding(
              width,
            );
            final maxWidth = AppBreakpoints.pageMaxContentWidth(width);
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: AppSpacing.lg,
                  ),
                  child: Column(
                    children: [
                      // Title field
                      TextField(
                        controller: _titleController,
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Note title',
                          hintStyle: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: secondaryText,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: null,
                      ),
                      Divider(color: borderColor, height: AppSpacing.xl),
                      // Content field
                      TextField(
                        controller: _contentController,
                        style: AppTextStyles.bodyMedium.copyWith(height: 1.8),
                        decoration: InputDecoration(
                          hintText: 'Start writing your notes...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: secondaryText,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: null,
                        minLines: 20,
                        keyboardType: TextInputType.multiline,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showAiAssist(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final lightBg = isDark
        ? AppColorsDark.lightBackground
        : AppColorsLight.lightBackground;
    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;
    final promptController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark
          ? AppColorsDark.background
          : AppColorsLight.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.xl,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'AI Assist',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Describe what you want to add to your notes',
              style: AppTextStyles.bodySmall.copyWith(color: secondaryText),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              decoration: BoxDecoration(
                borderRadius: AppRadius.mdBorder,
                boxShadow: AppEffects.subtleDepth(Theme.of(context).brightness),
              ),
              child: TextField(
                controller: promptController,
                autofocus: true,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g. "Explain thermodynamics laws with examples"',
                  hintStyle: AppTextStyles.bodySmall.copyWith(
                    color: secondaryText,
                  ),
                  filled: true,
                  fillColor: lightBg,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.mdBorder,
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.mdBorder,
                    borderSide: BorderSide(color: borderColor),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: Text('Generate', style: AppTextStyles.button),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColorsDark.primaryButton
                      : AppColorsLight.primaryButton,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdBorder,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                onPressed: () {
                  final prompt = promptController.text.trim();
                  if (prompt.isNotEmpty) {
                    // Append the prompt as a placeholder for AI content
                    final current = _contentController.text;
                    _contentController.text =
                        '$current\n\n--- AI Generated ---\n[AI content for: $prompt]\n';
                    _contentController.selection = TextSelection.collapsed(
                      offset: _contentController.text.length,
                    );
                  }
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
