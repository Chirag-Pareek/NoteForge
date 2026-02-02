import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_outlined_button.dart';
import 'widgets/smart_action_card.dart';
import 'widgets/note_list_card.dart';
import 'widgets/practice_card.dart';

/// StudyHubScreen
/// --------------
/// Main hub screen where users:
/// - Search content
/// - Access AI tools
/// - View notes
/// - Practice MCQs
/// - Use smart study features
///
/// Stateless because:
/// - No local state is managed here
/// - All interactions are delegated via callbacks
class StudyHubScreen extends StatelessWidget {
  const StudyHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /// Detect current theme (light / dark)
    final isDark = Theme.of(context).brightness == Brightness.dark;

    /// Theme-aware colors from centralized design system
    final borderColor =
        isDark ? AppColorsDark.border : AppColorsLight.border;

    final lightBg =
        isDark ? AppColorsDark.lightBackground : AppColorsLight.lightBackground;

    final secondaryText =
        isDark ? AppColorsDark.secondaryText : AppColorsLight.secondaryText;

    return Scaffold(
      /// Top app bar (no back button, center title)
      appBar: AppBar(
        centerTitle: true,
        leading: const SizedBox(), // removes back arrow
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Study Hub', style: AppTextStyles.bodyLarge),
      ),

      /// Entire screen scrolls vertically
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
                  borderRadius: BorderRadius.circular(999), // pill shape
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

              /// Grid of quick-access AI and study actions
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

              // ─────────────────────────────
              // SECTION 2: MY NOTES
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

              /// Individual note cards
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

              /// Button to generate a new note
              AppOutlinedButton(
                label: 'Generate New Note',
                isFullWidth: true,
                onPressed: () {},
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

              /// Two-column practice cards
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
