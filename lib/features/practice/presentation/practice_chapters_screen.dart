import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/app_progress_indicator.dart';
import '../../../core/routes/app_routes.dart';
import '../../notes/presentation/controllers/notes_controller.dart';
import 'controllers/practice_controller.dart';

/// Shows chapters of a subject for selecting which chapter to practice.
class PracticeChaptersScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;

  const PracticeChaptersScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<PracticeChaptersScreen> createState() => _PracticeChaptersScreenState();
}

class _PracticeChaptersScreenState extends State<PracticeChaptersScreen> {
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
        title: Text(
          'Practice — ${widget.subjectName}',
          style: AppTextStyles.titleMedium,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Consumer2<NotesController, PracticeController>(
        builder: (context, noteCtrl, practiceCtrl, _) {
          if (noteCtrl.isLoading && noteCtrl.chapters.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (noteCtrl.chapters.isEmpty) {
            return Center(
              child: Text(
                'No chapters in this subject',
                style: AppTextStyles.bodyLarge.copyWith(color: secondaryText),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: noteCtrl.chapters.length,
            separatorBuilder: (_, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final chapter = noteCtrl.chapters[index];
              final attempts = practiceCtrl.getChapterAttempts(chapter.id);
              final accuracy = practiceCtrl.getChapterAccuracy(chapter.id);

              return InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.practiceSession,
                    arguments: {
                      'chapterId': chapter.id,
                      'subjectId': widget.subjectId,
                      'chapterName': chapter.name,
                    },
                  );
                },
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
                            child: Text(
                              chapter.name,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColorsDark.lightBackground
                                  : AppColorsLight.lightBackground,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              attempts > 0
                                  ? '${accuracy.toInt()}% avg'
                                  : 'Not attempted',
                              style: AppTextStyles.label.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (attempts > 0) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '$attempts attempt${attempts > 1 ? 's' : ''}',
                          style: AppTextStyles.label.copyWith(
                            color: secondaryText,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppProgressIndicator(value: accuracy / 100),
                      ],
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
}
