import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_progress_indicator.dart';
import '../../../core/routes/app_routes.dart';
import 'controllers/notes_controller.dart';

/// Chapters list for a subject. Shows progress indicator per chapter.
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
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectName, style: AppTextStyles.titleMedium),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addChapter(context),
        backgroundColor: isDark
            ? AppColorsDark.primaryButton
            : AppColorsLight.primaryButton,
        foregroundColor: isDark ? Colors.black : Colors.white,
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

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: ctrl.chapters.length,
            separatorBuilder: (_, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final chapter = ctrl.chapters[index];
              return InkWell(
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
                borderRadius: AppRadius.mdBorder,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: AppRadius.mdBorder,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chapter.name,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '${chapter.topicsCount} topics • Updated ${_formatDate(chapter.updatedAt)}',
                                  style: AppTextStyles.label.copyWith(
                                    color: secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${(chapter.progress * 100).toInt()}%',
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Icon(
                            Icons.chevron_right,
                            color: secondaryText,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppProgressIndicator(value: chapter.progress),
                    ],
                  ),
                ),
              );
            },
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
