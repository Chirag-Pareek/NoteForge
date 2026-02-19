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

/// Chapters list for a subject.
class ChaptersScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;

  const ChaptersScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesController>().loadChapters(widget.subjectId);
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
        title: Text(widget.subjectName, style: AppTextStyles.titleMedium),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addChapter(context),
        // FIX: create button color corrected (light=white, dark=black).
        backgroundColor: fabBackground,
        foregroundColor: fabForeground,
        shape: CircleBorder(side: BorderSide(color: fabBorder)),
        child: const Icon(Icons.add),
      ),
      body: Consumer<NotesController>(
        builder: (context, ctrl, _) {
          if (ctrl.isLoading && ctrl.chapters.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.chapters.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: secondaryText),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No chapters yet',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: secondaryText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tap + to add a chapter',
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
                itemCount: ctrl.chapters.length,
                separatorBuilder: (_, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final chapter = ctrl.chapters[index];
                  // FIX: corrected chapter card to use AppCard via NoteListCard.
                  return NoteListCard(
                    icon: Icons.book_outlined,
                    title: chapter.name,
                    subtitle:
                        '${chapter.topicsCount} topics \u2022 Updated ${_formatDate(chapter.updatedAt)}',
                    trailingText: '${(chapter.progress * 100).toInt()}%',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.topics,
                        arguments: {
                          'chapterId': chapter.id,
                          'subjectId': widget.subjectId,
                          'chapterName': chapter.name,
                        },
                      );
                    },
                    onLongPress: () =>
                        _showOptions(context, chapter.id, chapter.name),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _addChapter(BuildContext context) async {
    final name = await AppDialog.showInputDialog(
      context: context,
      title: 'New Chapter',
      hint: 'Enter chapter name',
      confirmLabel: 'Create',
    );
    if (name == null || !context.mounted) return;
    context.read<NotesController>().addChapter(widget.subjectId, name);
  }

  void _showOptions(BuildContext context, String id, String name) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text('Edit', style: AppTextStyles.bodyMedium),
              onTap: () async {
                Navigator.pop(ctx);
                final newName = await AppDialog.showInputDialog(
                  context: context,
                  title: 'Edit Chapter',
                  initialValue: name,
                );
                if (newName != null && context.mounted) {
                  context.read<NotesController>().updateChapter(
                    id,
                    name: newName,
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: isDark ? AppColorsDark.error : AppColorsLight.error,
              ),
              title: Text(
                'Delete',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColorsDark.error : AppColorsLight.error,
                ),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final confirm = await AppDialog.showConfirmDialog(
                  context: context,
                  title: 'Delete Chapter',
                  message: 'Delete "$name" and all its topics?',
                );
                if (confirm && context.mounted) {
                  context.read<NotesController>().deleteChapter(
                    id,
                    widget.subjectId,
                  );
                }
              },
            ),
          ],
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
