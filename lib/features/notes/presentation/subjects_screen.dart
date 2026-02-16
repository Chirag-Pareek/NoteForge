import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_effects.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/routes/app_routes.dart';
import 'controllers/notes_controller.dart';

/// Lists all subjects with CRUD support.
class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesController>().loadSubjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final cardColor = isDark
        ? AppColorsDark.lightBackground
        : AppColorsLight.background;

    return Scaffold(
      appBar: AppBar(
        title: Text('Subjects', style: AppTextStyles.titleMedium),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addSubject(context),
        backgroundColor: isDark
            ? AppColorsDark.primaryButton
            : AppColorsLight.primaryButton,
        foregroundColor: isDark ? Colors.black : Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Consumer<NotesController>(
        builder: (context, ctrl, _) {
          if (ctrl.isLoading && ctrl.subjects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.subjects.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 64,
                    color: secondaryText,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No subjects yet',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: secondaryText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tap + to create your first subject',
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
                itemCount: ctrl.subjects.length,
                separatorBuilder: (_, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final subject = ctrl.subjects[index];
                  final accent = Color(
                    int.tryParse(subject.color) ?? 0xFF6B7280,
                  );
                  return InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.chapters,
                        arguments: {
                          'subjectId': subject.id,
                          'subjectName': subject.name,
                        },
                      );
                    },
                    onLongPress: () =>
                        _showOptions(context, subject.id, subject.name),
                    borderRadius: AppRadius.mdBorder,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: cardColor,
                        border: Border.all(color: borderColor),
                        borderRadius: AppRadius.mdBorder,
                        boxShadow: AppEffects.subtleDepth(brightness),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Icon(
                              Icons.folder_outlined,
                              color: accent,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subject.name,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '${subject.chaptersCount} chapters - Updated ${_formatDate(subject.updatedAt)}',
                                  style: AppTextStyles.label.copyWith(
                                    color: secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: secondaryText,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _addSubject(BuildContext context) async {
    final name = await AppDialog.showInputDialog(
      context: context,
      title: 'New Subject',
      hint: 'Enter subject name',
      confirmLabel: 'Create',
    );
    if (name == null || !context.mounted) return;
    context.read<NotesController>().addSubject(name);
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
                  title: 'Edit Subject',
                  initialValue: name,
                  hint: 'Subject name',
                );
                if (newName != null && context.mounted) {
                  context.read<NotesController>().updateSubject(
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
                  title: 'Delete Subject',
                  message:
                      'Are you sure you want to delete "$name"? This cannot be undone.',
                );
                if (confirm && context.mounted) {
                  context.read<NotesController>().deleteSubject(id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
