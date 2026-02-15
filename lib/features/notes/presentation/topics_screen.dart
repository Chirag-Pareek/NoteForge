import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/routes/app_routes.dart';
import 'controllers/notes_controller.dart';

/// Topics list for a chapter.
class TopicsScreen extends StatefulWidget {
  final String chapterId;
  final String subjectId;
  final String chapterName;

  const TopicsScreen({
    super.key,
    required this.chapterId,
    required this.subjectId,
    required this.chapterName,
  });

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesController>().loadTopics(widget.chapterId);
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
        title: Text(widget.chapterName, style: AppTextStyles.titleMedium),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTopic(context),
        backgroundColor: isDark
            ? AppColorsDark.primaryButton
            : AppColorsLight.primaryButton,
        foregroundColor: isDark ? Colors.black : Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Consumer<NotesController>(
        builder: (context, ctrl, _) {
          if (ctrl.isLoading && ctrl.topics.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.topics.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.topic_outlined, size: 64, color: secondaryText),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No topics yet',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: secondaryText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tap + to add a topic',
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
            itemCount: ctrl.topics.length,
            separatorBuilder: (_, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final topic = ctrl.topics[index];
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.notesList,
                    arguments: {
                      'topicId': topic.id,
                      'chapterId': widget.chapterId,
                      'subjectId': widget.subjectId,
                      'topicName': topic.name,
                    },
                  );
                },
                onLongPress: () => _showOptions(context, topic.id, topic.name),
                borderRadius: AppRadius.mdBorder,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: AppRadius.mdBorder,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.article_outlined,
                        color: secondaryText,
                        size: 22,
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topic.name,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${topic.notesCount} notes • Updated ${_formatDate(topic.updatedAt)}',
                              style: AppTextStyles.label.copyWith(
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: secondaryText, size: 20),
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

  Future<void> _addTopic(BuildContext context) async {
    final name = await AppDialog.showInputDialog(
      context: context,
      title: 'New Topic',
      hint: 'Enter topic name',
      confirmLabel: 'Create',
    );
    if (name == null || !context.mounted) return;
    context.read<NotesController>().addTopic(
      widget.chapterId,
      widget.subjectId,
      name,
    );
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
                  title: 'Edit Topic',
                  initialValue: name,
                );
                if (newName != null && context.mounted) {
                  context.read<NotesController>().updateTopic(
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
                  title: 'Delete Topic',
                  message: 'Delete "$name" and all its notes?',
                );
                if (confirm && context.mounted) {
                  context.read<NotesController>().deleteTopic(
                    id,
                    widget.chapterId,
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
