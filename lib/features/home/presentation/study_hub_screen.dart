import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_outlined_button.dart';
import 'widgets/smart_action_card.dart';
import 'widgets/note_list_card.dart';
import 'widgets/practice_card.dart';

class StudyHubScreen extends StatelessWidget {
  const StudyHubScreen({super.key});

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
        title: Text('Study Hub', style: AppTextStyles.bodyLarge),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
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

              // Section 1: Smart Actions
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
                    label: 'Solve Notes',
                    onTap: () {},
                  ),
                  SmartActionCard(
                    icon: Icons.note_add_outlined,
                    label: 'Create Notes',
                    onTap: () {},
                  ),
                  SmartActionCard(
                    icon: Icons.quiz_outlined,
                    label: 'MCQs',
                    onTap: () {},
                  ),
                  SmartActionCard(
                    icon: Icons.picture_as_pdf_outlined,
                    label: 'PDFs',
                    onTap: () {},
                  ),
                  SmartActionCard(
                    icon: Icons.menu_book_outlined,
                    label: 'Books',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Section 2: My Notes
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
                    onTap: () {},
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

              NoteListCard(
                title: 'Physics - Thermodynamics',
                subtitle: 'Updated 2 days ago',
                onTap: () {},
              ),

              const SizedBox(height: AppSpacing.sm),

              NoteListCard(
                title: 'Math - Calculus Basics',
                subtitle: 'Updated 1 week ago',
                onTap: () {},
              ),

              const SizedBox(height: AppSpacing.md),

              AppOutlinedButton(
                label: 'Generate New Note',
                isFullWidth: true,
                onPressed: () {},
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Section 3: Practice Zone
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
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: PracticeCard(
                      icon: Icons.edit_outlined,
                      title: 'Fill Blanks',
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Section 4: Smart Study Tools
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
                onTap: () {},
              ),

              const SizedBox(height: AppSpacing.sm),

              NoteListCard(
                title: 'Revision Mode',
                subtitle: 'Smart spaced repetition',
                onTap: () {},
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
