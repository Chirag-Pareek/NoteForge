import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';

/// Displays the results after completing a practice session.
class PracticeResultsScreen extends StatelessWidget {
  final String sessionId;
  final int correct;
  final int total;
  final double accuracy;
  final List<String> weakTopics;

  const PracticeResultsScreen({
    super.key,
    required this.sessionId,
    required this.correct,
    required this.total,
    required this.accuracy,
    required this.weakTopics,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;

    Color scoreColor;
    String scoreLabel;
    IconData scoreIcon;
    if (accuracy >= 80) {
      scoreColor = const Color(0xFF22C55E);
      scoreLabel = 'Excellent!';
      scoreIcon = Icons.emoji_events_outlined;
    } else if (accuracy >= 60) {
      scoreColor = const Color(0xFFF59E0B);
      scoreLabel = 'Good effort!';
      scoreIcon = Icons.thumb_up_alt_outlined;
    } else {
      scoreColor = const Color(0xFFEF4444);
      scoreLabel = 'Keep practicing!';
      scoreIcon = Icons.auto_fix_high_outlined;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Results', style: AppTextStyles.titleMedium),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              // Score circle
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scoreColor.withValues(alpha: 0.12),
                  border: Border.all(color: scoreColor, width: 3),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${accuracy.toInt()}%',
                      style: AppTextStyles.display.copyWith(
                        color: scoreColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Icon(scoreIcon, size: 28, color: scoreColor),
              const SizedBox(height: AppSpacing.sm),
              Text(
                scoreLabel,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$correct out of $total correct',
                style: AppTextStyles.bodyMedium.copyWith(color: secondaryText),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Stats row
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: AppRadius.mdBorder,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ResultStat(
                      label: 'Correct',
                      value: '$correct',
                      color: const Color(0xFF22C55E),
                    ),
                    _ResultStat(
                      label: 'Incorrect',
                      value: '${total - correct}',
                      color: const Color(0xFFEF4444),
                    ),
                    _ResultStat(
                      label: 'Accuracy',
                      value: '${accuracy.toInt()}%',
                      color: scoreColor,
                    ),
                  ],
                ),
              ),

              // Weak topics
              if (weakTopics.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Areas to improve',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...weakTopics.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
                        ),
                        borderRadius: AppRadius.mdBorder,
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.06),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_outlined,
                            size: 16,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(t, style: AppTextStyles.bodySmall),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),
              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColorsDark.primaryButton
                        : AppColorsLight.primaryButton,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mdBorder,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                  child: Text('Done', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTextStyles.label),
      ],
    );
  }
}
