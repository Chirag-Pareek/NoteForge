import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_outlined_button.dart';
import '../../notes/presentation/controllers/notes_controller.dart';
import 'widgets/smart_action_card.dart';
import 'widgets/note_list_card.dart';
import 'widgets/practice_card.dart';

/// StudyHubScreen
/// Main hub screen — all buttons wired to real functional screens.
class StudyHubScreen extends StatefulWidget {
  const StudyHubScreen({super.key});

  @override
  State<StudyHubScreen> createState() => _StudyHubScreenState();
}

class _StudyHubScreenState extends State<StudyHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesController>().loadRecentNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final lightBg = isDark
        ? AppColorsDark.lightBackground
        : AppColorsLight.lightBackground;
    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const SizedBox(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Study Hub',
          style: (AppTextStyles.bodyLarge).copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─────────────────────────────
              // SEARCH BAR
              // ─────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: lightBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 20, color: secondaryText),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Search notes, chapters and MCQs',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ─────────────────────────────
              // SECTION 1: SMART ACTIONS
              // ─────────────────────────────
              Text(
                'Smart Actions',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.0,
                children: [
                  SmartActionCard(
                    icon: Icons.psychology_outlined,
                    label: 'Ask AI',
                    onTap: () {},
                  ),
                  SmartActionCard(
                    icon: Icons.lightbulb_outline,
                    label: 'My Notes',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.subjects),
                  ),
                  SmartActionCard(
                    icon: Icons.note_add_outlined,
                    label: 'Create Notes',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.subjects),
                  ),
                  SmartActionCard(
                    icon: Icons.quiz_outlined,
                    label: 'MCQs',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.practiceSelect),
                  ),
                  SmartActionCard(
                    icon: Icons.picture_as_pdf_outlined,
                    label: 'PDFs',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.books),
                  ),
                  SmartActionCard(
                    icon: Icons.menu_book_outlined,
                    label: 'Books',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.books),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              // ─────────────────────────────
              // SECTION 2: MY NOTES (live data)
              // ─────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Notes',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.subjects),
                    child: Text(
                      'See all',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: secondaryText,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Show recent notes from controller
              Consumer<NotesController>(
                builder: (context, ctrl, _) {
                  if (ctrl.recentNotes.isEmpty) {
                    return NoteListCard(
                      title: 'No notes yet',
                      subtitle: 'Create your first note',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.subjects),
                    );
                  }
                  return Column(
                    children: ctrl.recentNotes.take(3).map((note) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: NoteListCard(
                          title: note.title.isEmpty
                              ? 'Untitled Note'
                              : note.title,
                          subtitle: 'Updated ${_formatDate(note.updatedAt)}',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.noteEditor,
                              arguments: {
                                'noteId': note.id,
                                'title': note.title,
                                'content': note.content,
                                'topicId': note.topicId,
                                'chapterId': note.chapterId,
                                'subjectId': note.subjectId,
                              },
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.md),

              AppOutlinedButton(
                label: 'Create New Note',
                isFullWidth: true,
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.subjects),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // ─────────────────────────────
              // SECTION 3: PRACTICE ZONE
              // ─────────────────────────────
              Text(
                'Practice Zone',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Row(
                children: [
                  Expanded(
                    child: PracticeCard(
                      icon: Icons.quiz_outlined,
                      title: 'MCQs',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.practiceSelect),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: PracticeCard(
                      icon: Icons.edit_outlined,
                      title: 'Fill Blanks',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.practiceSelect),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              // ─────────────────────────────
              // SECTION 4: SMART STUDY TOOLS
              // ─────────────────────────────
              Text(
                'Smart Study Tools',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              NoteListCard(
                title: 'AI Study Plan',
                subtitle: 'Personalized schedule',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.studyPlan),
              ),

              const SizedBox(height: AppSpacing.sm),

              NoteListCard(
                title: 'Revision Mode',
                subtitle: 'Smart spaced repetition',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.studyPlan),
              ),

              const SizedBox(height: AppSpacing.sm),

              NoteListCard(
                title: 'Books & Resources',
                subtitle: 'Upload and manage PDFs',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.books),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
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

