import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/app_progress_indicator.dart';
import '../../../core/routes/app_routes.dart';
import '../domain/practice_question_model.dart';
import 'controllers/practice_controller.dart';

/// The active practice quiz screen. Supports MCQ, fill-blank, and short answer.
class PracticeSessionScreen extends StatefulWidget {
  final String chapterId;
  final String subjectId;
  final String chapterName;

  const PracticeSessionScreen({
    super.key,
    required this.chapterId,
    required this.subjectId,
    required this.chapterName,
  });

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> {
  final _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PracticeController>().startSession(
        widget.chapterId,
        widget.subjectId,
      );
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
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
      body: Consumer<PracticeController>(
        builder: (context, ctrl, _) {
          if (ctrl.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.quiz_outlined, size: 64, color: secondaryText),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No questions available',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: secondaryText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Questions will be generated when you add notes.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: secondaryText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final q = ctrl.currentQuestion!;
          final selectedAnswer = ctrl.answers[q.id] ?? '';

          return Column(
            children: [
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${ctrl.currentIndex + 1} / ${ctrl.totalQuestions}',
                      style: AppTextStyles.label.copyWith(color: secondaryText),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AppProgressIndicator(value: ctrl.progress),
                  ],
                ),
              ),

              // Question
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type badge
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
                          q.type == QuestionType.mcq
                              ? 'Multiple Choice'
                              : q.type == QuestionType.fillBlank
                              ? 'Fill in the Blank'
                              : 'Short Answer',
                          style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        q.question,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Answer input based on type
                      if (q.type == QuestionType.mcq)
                        ...q.options.map((opt) {
                          final isSelected = selectedAnswer == opt;
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: InkWell(
                              onTap: () => ctrl.selectAnswer(opt),
                              borderRadius: AppRadius.mdBorder,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected
                                        ? (isDark
                                              ? AppColorsDark.primaryText
                                              : AppColorsLight.primaryText)
                                        : borderColor,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: AppRadius.mdBorder,
                                  color: isSelected
                                      ? (isDark
                                                ? AppColorsDark.primaryText
                                                : AppColorsLight.primaryText)
                                            .withValues(alpha: 0.08)
                                      : null,
                                ),
                                child: Text(
                                  opt,
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ),
                            ),
                          );
                        }),

                      if (q.type == QuestionType.fillBlank ||
                          q.type == QuestionType.shortAnswer)
                        TextField(
                          controller: _answerController,
                          onChanged: (v) => ctrl.selectAnswer(v),
                          decoration: InputDecoration(
                            hintText: q.type == QuestionType.fillBlank
                                ? 'Type your answer'
                                : 'Write a short answer',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: secondaryText,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.mdBorder,
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.mdBorder,
                              borderSide: BorderSide(color: borderColor),
                            ),
                          ),
                          maxLines: q.type == QuestionType.shortAnswer ? 4 : 1,
                        ),
                    ],
                  ),
                ),
              ),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    if (ctrl.currentIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ctrl.previousQuestion();
                            _answerController.text =
                                ctrl.answers[ctrl.currentQuestion?.id] ?? '';
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.mdBorder,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                          ),
                          child: Text('Previous', style: AppTextStyles.button),
                        ),
                      ),
                    if (ctrl.currentIndex > 0)
                      const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (ctrl.currentIndex < ctrl.totalQuestions - 1) {
                            ctrl.nextQuestion();
                            _answerController.text =
                                ctrl.answers[ctrl.currentQuestion?.id] ?? '';
                          } else {
                            // Finish session
                            final session = await ctrl.finishSession();
                            if (session != null && context.mounted) {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.practiceResults,
                                arguments: {
                                  'sessionId': session.id,
                                  'correct': session.correctAnswers,
                                  'total': session.totalQuestions,
                                  'accuracy': session.accuracy,
                                  'weakTopics': session.weakTopics,
                                },
                              );
                            }
                          }
                        },
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
                        child: Text(
                          ctrl.currentIndex < ctrl.totalQuestions - 1
                              ? 'Next'
                              : 'Finish',
                          style: AppTextStyles.button,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
