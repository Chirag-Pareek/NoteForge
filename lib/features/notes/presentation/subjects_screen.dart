import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/theme/app_effects.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/routes/app_routes.dart';
import '../../home/presentation/widgets/note_list_card.dart';
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
    final fabBackground = isDark
        ? AppColorsDark.background
        : AppColorsLight.background;
    final fabForeground = isDark
        ? AppColorsDark.primaryText
        : AppColorsLight.primaryText;
    final fabBorder = secondaryText.withAlpha((0.38 * 255).toInt());
    return Scaffold(
      appBar: AppBar(
        title: Text('Subjects', style: AppTextStyles.titleMedium),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addSubject(context),
        // FIX: create button color corrected (light=white, dark=black).
        backgroundColor: fabBackground,
        foregroundColor: fabForeground,
        shape: CircleBorder(side: BorderSide(color: fabBorder)),
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
                  // FIX: corrected subject card to use AppCard via NoteListCard.
                  return NoteListCard(
                    icon: Icons.folder_outlined,
                    title: subject.name,
                    subtitle:
                        '${subject.chaptersCount} chapters \u2022 Updated ${_formatDate(subject.updatedAt)}',
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
    final subjectDraft = await _showCreateSubjectSheet(context);
    if (subjectDraft == null || !context.mounted) return;
    context.read<NotesController>().addSubject(
      subjectDraft.name,
      description: subjectDraft.description,
    );
  }

  Future<_SubjectDraft?> _showCreateSubjectSheet(BuildContext context) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final lightBg = isDark
        ? AppColorsDark.lightBackground
        : AppColorsLight.lightBackground;
    final primaryText = isDark
        ? AppColorsDark.primaryText
        : AppColorsLight.primaryText;
    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;
    final surfaceBg = isDark
        ? AppColorsDark.background
        : AppColorsLight.background;

    int wordCount = 0;
    String? validationMessage;

    final result = await showModalBottomSheet<_SubjectDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
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
                    'New Subject',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.mdBorder,
                      boxShadow: AppEffects.subtleDepth(
                        Theme.of(context).brightness,
                      ),
                    ),
                    child: TextField(
                      controller: nameController,
                      autofocus: true,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: primaryText,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter subject name',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
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
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.mdBorder,
                          borderSide: BorderSide(color: primaryText),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.mdBorder,
                      boxShadow: AppEffects.subtleDepth(
                        Theme.of(context).brightness,
                      ),
                    ),
                    child: TextField(
                      controller: descriptionController,
                      minLines: 4,
                      maxLines: 6,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: primaryText,
                      ),
                      onChanged: (value) {
                        setSheetState(() {
                          wordCount = _countWords(value);
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter subject description (optional)',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
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
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.mdBorder,
                          borderSide: BorderSide(color: primaryText),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '$wordCount/50 words',
                    style: AppTextStyles.label.copyWith(color: secondaryText),
                  ),
                  if (validationMessage != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      validationMessage!,
                      style: AppTextStyles.label.copyWith(
                        color: isDark
                            ? AppColorsDark.error
                            : AppColorsLight.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: surfaceBg,
                            foregroundColor: primaryText,
                            side: BorderSide(color: borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.mdBorder,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.button.copyWith(
                              color: primaryText,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final name = nameController.text.trim();
                            final description = descriptionController.text
                                .trim();

                            if (name.isEmpty) {
                              setSheetState(() {
                                validationMessage = 'Subject name is required.';
                              });
                              return;
                            }

                            Navigator.pop(
                              ctx,
                              _SubjectDraft(
                                name: name,
                                description: description,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColorsDark.primaryButton
                                : AppColorsLight.primaryButton,
                            foregroundColor: isDark
                                ? Colors.black
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.mdBorder,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                          ),
                          child: Text(
                            'Create',
                            style: AppTextStyles.button.copyWith(
                              color: isDark ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    // Keep controllers unmanaged here to avoid dispose-during-dismiss issues
    // when the sheet is closed via Cancel/backdrop tap.
    return result;
  }

  int _countWords(String text) {
    final parts = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty);
    return parts.length;
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

class _SubjectDraft {
  final String name;
  final String description;

  const _SubjectDraft({required this.name, required this.description});
}
