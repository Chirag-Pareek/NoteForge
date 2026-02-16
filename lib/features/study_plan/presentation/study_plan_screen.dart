import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_effects.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_progress_indicator.dart';
import '../../notes/presentation/controllers/notes_controller.dart';
import 'controllers/study_plan_controller.dart';

/// Smart Study Plan screen showing today's plan, revision queue, and streak.
class StudyPlanScreen extends StatefulWidget {
  const StudyPlanScreen({super.key});

  @override
  State<StudyPlanScreen> createState() => _StudyPlanScreenState();
}

class _StudyPlanScreenState extends State<StudyPlanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = context.read<StudyPlanController>();
      ctrl.loadTodayPlan();
      ctrl.loadRevisions();
      ctrl.calculateStreak();
      context.read<NotesController>().loadSubjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColorsDark.background
        : AppColorsLight.background;
    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalPadding = AppBreakpoints.pageHorizontalPadding(width);
        final maxWidth = AppBreakpoints.pageMaxContentWidth(width);

        return Scaffold(
          appBar: AppBar(
            title: Text('Smart Study', style: AppTextStyles.titleMedium),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: Consumer<StudyPlanController>(
            builder: (context, ctrl, _) {
              if (ctrl.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            border: Border.all(color: borderColor),
                            borderRadius: AppRadius.mdBorder,
                            boxShadow: AppEffects.subtleDepth(brightness),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFF59E0B,
                                  ).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.local_fire_department_outlined,
                                  color: Color(0xFFF59E0B),
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${ctrl.currentStreak} day streak',
                                      style: AppTextStyles.titleMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      ctrl.currentStreak > 0
                                          ? 'Keep it going!'
                                          : 'Start studying to build your streak',
                                      style: AppTextStyles.label.copyWith(
                                        color: secondaryText,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Today's Plan",
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (ctrl.todayPlan == null)
                              TextButton.icon(
                                icon: const Icon(Icons.auto_awesome, size: 16),
                                label: Text(
                                  'Generate',
                                  style: AppTextStyles.label.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onPressed: () => _generatePlan(context),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        if (ctrl.todayPlan == null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              border: Border.all(color: borderColor),
                              borderRadius: AppRadius.mdBorder,
                              boxShadow: AppEffects.subtleDepth(brightness),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_note_outlined,
                                  size: 48,
                                  color: secondaryText,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  'No plan for today',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: secondaryText,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Tap Generate to create a study plan',
                                  style: AppTextStyles.label.copyWith(
                                    color: secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              border: Border.all(color: borderColor),
                              borderRadius: AppRadius.mdBorder,
                              boxShadow: AppEffects.subtleDepth(brightness),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${(ctrl.todayPlan!.completionRatio * 100).toInt()}% complete',
                                      style: AppTextStyles.label.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${ctrl.todayPlan!.totalMinutes} min',
                                      style: AppTextStyles.label.copyWith(
                                        color: secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                AppProgressIndicator(
                                  value: ctrl.todayPlan!.completionRatio,
                                  activeColor: const Color(0xFF22C55E),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          ...ctrl.todayPlan!.tasks.asMap().entries.map((entry) {
                            final i = entry.key;
                            final task = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: InkWell(
                                onTap: () =>
                                    ctrl.toggleTask(i, !task.isCompleted),
                                borderRadius: AppRadius.mdBorder,
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  decoration: BoxDecoration(
                                    color: surfaceColor,
                                    border: Border.all(color: borderColor),
                                    borderRadius: AppRadius.mdBorder,
                                    boxShadow: AppEffects.subtleDepth(
                                      brightness,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        task.isCompleted
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        color: task.isCompleted
                                            ? const Color(0xFF22C55E)
                                            : secondaryText,
                                        size: 22,
                                      ),
                                      const SizedBox(width: AppSpacing.lg),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              task.chapterName.isNotEmpty
                                                  ? '${task.subjectName} - ${task.chapterName}'
                                                  : task.subjectName,
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    decoration: task.isCompleted
                                                        ? TextDecoration
                                                              .lineThrough
                                                        : null,
                                                  ),
                                            ),
                                            const SizedBox(
                                              height: AppSpacing.xs,
                                            ),
                                            Text(
                                              '${task.type.name.toUpperCase()} - ${task.durationMinutes} min',
                                              style: AppTextStyles.label
                                                  .copyWith(
                                                    color: secondaryText,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],

                        const SizedBox(height: AppSpacing.xl),

                        Text(
                          'Revision Due',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        if (ctrl.dueRevisions.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              border: Border.all(color: borderColor),
                              borderRadius: AppRadius.mdBorder,
                              boxShadow: AppEffects.subtleDepth(brightness),
                            ),
                            child: Text(
                              'No topics due for revision',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: secondaryText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ...ctrl.dueRevisions.map((rev) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  border: Border.all(color: borderColor),
                                  borderRadius: AppRadius.mdBorder,
                                  boxShadow: AppEffects.subtleDepth(brightness),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.replay_outlined,
                                      color: Color(0xFFF59E0B),
                                      size: 22,
                                    ),
                                    const SizedBox(width: AppSpacing.lg),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            rev.topicName,
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            'Interval: ${rev.interval} day${rev.interval > 1 ? 's' : ''}',
                                            style: AppTextStyles.label.copyWith(
                                              color: secondaryText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _ReviewButton(
                                          label: 'Hard',
                                          color: const Color(0xFFEF4444),
                                          onTap: () => ctrl.reviewTopic(rev, 2),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        _ReviewButton(
                                          label: 'Good',
                                          color: const Color(0xFFF59E0B),
                                          onTap: () => ctrl.reviewTopic(rev, 3),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        _ReviewButton(
                                          label: 'Easy',
                                          color: const Color(0xFF22C55E),
                                          onTap: () => ctrl.reviewTopic(rev, 5),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _generatePlan(BuildContext context) async {
    final subjects = context.read<NotesController>().subjects;
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add subjects first to generate a plan'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final subjectChapters = subjects
        .take(3)
        .map(
          (s) => {
            'subjectId': s.id,
            'subjectName': s.name,
            'chapterId': '',
            'chapterName': 'All chapters',
          },
        )
        .toList();

    await context.read<StudyPlanController>().generatePlan(
      subjectChapters: subjectChapters,
    );
  }
}

class _ReviewButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ReviewButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
