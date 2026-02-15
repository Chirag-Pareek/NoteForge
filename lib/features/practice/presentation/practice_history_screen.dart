import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import 'controllers/practice_controller.dart';

/// Shows past practice session history.
class PracticeHistoryScreen extends StatelessWidget {
  const PracticeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;

    return Scaffold(
      appBar: AppBar(
        title: Text('Practice History', style: AppTextStyles.titleMedium),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Consumer<PracticeController>(
        builder: (context, ctrl, _) {
          if (ctrl.sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_outlined, size: 64, color: secondaryText),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No history yet',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: ctrl.sessions.length,
            separatorBuilder: (_, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final s = ctrl.sessions[index];
              Color accentColor;
              if (s.accuracy >= 80) {
                accentColor = const Color(0xFF22C55E);
              } else if (s.accuracy >= 60) {
                accentColor = const Color(0xFFF59E0B);
              } else {
                accentColor = const Color(0xFFEF4444);
              }

              return Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: AppRadius.mdBorder,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withValues(alpha: 0.12),
                      ),
                      child: Center(
                        child: Text(
                          '${s.accuracy.toInt()}%',
                          style: AppTextStyles.label.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${s.correctAnswers}/${s.totalQuestions} correct',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _formatDate(s.completedAt),
                            style: AppTextStyles.label.copyWith(
                              color: secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (s.weakTopics.isNotEmpty)
                      Icon(
                        Icons.warning_amber_outlined,
                        size: 18,
                        color: const Color(0xFFF59E0B),
                      ),
                  ],
                ),
              );
            },
          );
        },
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
