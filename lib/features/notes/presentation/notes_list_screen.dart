import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../home/presentation/widgets/note_list_card.dart';
import 'controllers/notes_controller.dart';

/// Notes list for a topic.
class NotesListScreen extends StatefulWidget {
  final String topicId;
  final String chapterId;
  final String subjectId;
  final String topicName;

  const NotesListScreen({
    super.key,
    required this.topicId,
    required this.chapterId,
    required this.subjectId,
    required this.topicName,
  });

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesController>().loadNotes(widget.topicId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;
    final fabBackground = isDark
        ? AppColorsDark.background
        : AppColorsLight.background;
    final fabForeground = isDark
        ? AppColorsDark.primaryText
        : AppColorsLight.primaryText;
    final fabBorder = secondaryText.withAlpha((0.38 * 255).toInt());

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topicName, style: AppTextStyles.titleMedium),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNote(context),
        // FIX: create button color corrected (light=white, dark=black).
        backgroundColor: fabBackground,
        foregroundColor: fabForeground,
        shape: CircleBorder(side: BorderSide(color: fabBorder)),
        child: const Icon(Icons.add),
      ),
      body: Consumer<NotesController>(
        builder: (context, ctrl, _) {
          if (ctrl.isLoading && ctrl.notes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.note_outlined, size: 64, color: secondaryText),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No notes yet',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: secondaryText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tap + to create your first note',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
            );
          }

          final width = MediaQuery.sizeOf(context).width;
          final horizontalPadding = AppBreakpoints.pageHorizontalPadding(width);
          final maxWidth = AppBreakpoints.pageMaxContentWidth(width);

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: AppSpacing.lg,
                ),
                itemCount: ctrl.notes.length,
                separatorBuilder: (_, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final note = ctrl.notes[index];
                  final title = note.title.isEmpty
                      ? 'Untitled Note'
                      : note.title;
                  final subtitle = note.isDraft
                      ? 'Draft \u2022 Updated ${_formatDate(note.updatedAt)}'
                      : 'Updated ${_formatDate(note.updatedAt)}';

                  // FIX: corrected note card to use AppCard via NoteListCard.
                  return NoteListCard(
                    icon: Icons.note_outlined,
                    title: title,
                    subtitle: subtitle,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.noteEditor,
                        arguments: {
                          'noteId': note.id,
                          'title': note.title,
                          'content': note.content,
                          'topicId': widget.topicId,
                          'chapterId': widget.chapterId,
                          'subjectId': widget.subjectId,
                        },
                      );
                    },
                    onLongPress: () => _showDeleteOption(context, note.id),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _createNote(BuildContext context) async {
    final ctrl = context.read<NotesController>();
    final note = await ctrl.createNote(
      topicId: widget.topicId,
      chapterId: widget.chapterId,
      subjectId: widget.subjectId,
    );
    if (!context.mounted) return;
    Navigator.pushNamed(
      context,
      AppRoutes.noteEditor,
      arguments: {
        'noteId': note.id,
        'title': '',
        'content': '',
        'topicId': widget.topicId,
        'chapterId': widget.chapterId,
        'subjectId': widget.subjectId,
      },
    );
  }

  void _showDeleteOption(BuildContext context, String noteId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark
          ? AppColorsDark.background
          : AppColorsLight.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ListTile(
          leading: Icon(
            Icons.delete_outline,
            color: isDark ? AppColorsDark.error : AppColorsLight.error,
          ),
          title: Text(
            'Delete Note',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColorsDark.error : AppColorsLight.error,
            ),
          ),
          onTap: () async {
            Navigator.pop(ctx);
            final confirm = await AppDialog.showConfirmDialog(
              context: context,
              title: 'Delete Note',
              message: 'This note will be permanently deleted.',
            );
            if (confirm && context.mounted) {
              context.read<NotesController>().deleteNote(
                noteId,
                widget.topicId,
              );
            }
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
