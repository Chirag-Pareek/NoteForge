import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_effects.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/routes/app_routes.dart';
import '../../notes/presentation/controllers/notes_controller.dart';
import '../presentation/controllers/practice_controller.dart';

/// Lets user pick a chapter to start a practice session.
class PracticeSelectScreen extends StatefulWidget {
  const PracticeSelectScreen({super.key});

  @override
  State<PracticeSelectScreen> createState() => _PracticeSelectScreenState();
}

class _PracticeSelectScreenState extends State<PracticeSelectScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesController>().loadSubjects();
      context.read<PracticeController>().loadHistory();
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Practice', style: AppTextStyles.titleMedium),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined),
            tooltip: 'History',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.practiceHistory),
          ),
        ],
      ),
      body: Consumer2<NotesController, PracticeController>(
        builder: (context, noteCtrl, practiceCtrl, _) {
          if (noteCtrl.isLoading && noteCtrl.subjects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (noteCtrl.subjects.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.quiz_outlined, size: 64, color: secondaryText),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No subjects available',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: secondaryText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Add subjects in Notes first.',
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
                    // Quick stats
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        border: Border.all(color: borderColor),
                        borderRadius: AppRadius.mdBorder,
                        boxShadow: AppEffects.subtleDepth(brightness),
                      ),
                      child: Row(
                        children: [
                          _StatItem(
                            label: 'Sessions',
                            value: '${practiceCtrl.sessions.length}',
                            icon: Icons.check_circle_outline,
                            isDark: isDark,
                          ),
                          _StatItem(
                            label: 'Avg Score',
                            value: practiceCtrl.sessions.isEmpty
                                ? '—'
                                : '${practiceCtrl.sessions.fold<double>(0, (s, e) => s + e.accuracy) ~/ practiceCtrl.sessions.length}%',
                            icon: Icons.bar_chart_outlined,
                            isDark: isDark,
                          ),
                          _StatItem(
                            label: 'Weak',
                            value: '${practiceCtrl.getWeakTopics().length}',
                            icon: Icons.warning_amber_outlined,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Select a subject',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Subject list
                    ...noteCtrl.subjects.map((subject) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.practiceChapters,
                              arguments: {
                                'subjectId': subject.id,
                                'subjectName': subject.name,
                              },
                            );
                          },
                          borderRadius: AppRadius.mdBorder,
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
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Color(
                                      int.tryParse(subject.color) ?? 0xFF6B7280,
                                    ).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.quiz_outlined,
                                    color: Color(
                                      int.tryParse(subject.color) ?? 0xFF6B7280,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: Text(
                                    subject.name,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
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
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: isDark
                ? AppColorsDark.secondaryText
                : AppColorsLight.secondaryText,
            size: 20,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: isDark
                  ? AppColorsDark.secondaryText
                  : AppColorsLight.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
