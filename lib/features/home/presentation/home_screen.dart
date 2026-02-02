import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/app_card.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../../core/responsive/app_breakpoints.dart';

/// HomeScreen is the main dashboard screen after login.
/// It is RESPONSIVE and adapts for mobile, tablet, and desktop widths.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// AuthController is created once when the screen initializes.
  /// This avoids recreating controllers inside build().
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
  }

  @override
  void dispose() {
    /// Always dispose controllers to avoid memory leaks
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Detect current theme mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    /// Resolve theme-based colors
    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;

    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;

    final lightBg = isDark
        ? AppColorsDark.lightBackground
        : AppColorsLight.lightBackground;

    /// LayoutBuilder allows us to respond to screen width
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        /// Centralized responsive breakpoints
        final isTablet = !AppBreakpoints.isMobile(width); // > 600
        final isLargeTablet = AppBreakpoints.isDesktop(width); // > 900

        /// Responsive values
        final horizontalPadding = isTablet ? AppSpacing.xxl * 2 : AppSpacing.lg;

        final gridColumns = isLargeTablet ? 4 : (isTablet ? 3 : 2);

        final titleFontSize = isLargeTablet ? 56.0 : (isTablet ? 48.0 : null);

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: const SizedBox(), // removes back button
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: Text(
              'NoteForge',
              style:
                  (isTablet ? AppTextStyles.display : AppTextStyles.bodyLarge)
                      .copyWith(fontWeight: FontWeight.w800),
            ),
          ),

          /// Main screen body
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: isTablet ? AppSpacing.xxl * 2 : AppSpacing.xl,
                      ),

                      /// Hero heading
                      Text(
                        'What can I help\nwith?',
                        style: titleFontSize != null
                            ? AppTextStyles.display.copyWith(
                                fontSize: titleFontSize,
                              )
                            : AppTextStyles.display,
                      ),

                      SizedBox(
                        height: isTablet ? AppSpacing.xxl * 2 : AppSpacing.xl,
                      ),

                      /// Action cards grid (responsive)
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: gridColumns,
                        mainAxisSpacing: isTablet
                            ? AppSpacing.lg
                            : AppSpacing.md,
                        crossAxisSpacing: isTablet
                            ? AppSpacing.lg
                            : AppSpacing.md,
                        childAspectRatio: isTablet ? 1.1 : 1.0,
                        children: [
                          _ActionCard(
                            icon: Icons.description_outlined,
                            title: 'Notes',
                            description: 'Create and organize study notes',
                            lightBg: lightBg,
                            secondaryText: secondaryText,
                            borderColor: borderColor,
                            isTablet: isTablet,
                          ),
                          _ActionCard(
                            icon: Icons.quiz_outlined,
                            title: 'MCQs',
                            description: 'Practice questions',
                            lightBg: lightBg,
                            secondaryText: secondaryText,
                            borderColor: borderColor,
                            isTablet: isTablet,
                          ),
                          _ActionCard(
                            icon: Icons.calendar_today_outlined,
                            title: 'Planner',
                            description: 'Schedule your study time',
                            lightBg: lightBg,
                            secondaryText: secondaryText,
                            borderColor: borderColor,
                            isTablet: isTablet,
                          ),
                          _ActionCard(
                            icon: Icons.auto_stories_outlined,
                            title: 'Summaries',
                            description: 'Quick chapter summaries',
                            lightBg: lightBg,
                            secondaryText: secondaryText,
                            borderColor: borderColor,
                            isTablet: isTablet,
                          ),
                        ],
                      ),

                      SizedBox(
                        height: isTablet ? AppSpacing.xxl * 2 : AppSpacing.xl,
                      ),

                      /// Bottom input bar (chat-style)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? AppSpacing.xl : AppSpacing.lg,
                          vertical: isTablet ? AppSpacing.lg : AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: lightBg,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Ask anything...',
                                style:
                                    (isTablet
                                            ? AppTextStyles.bodyLarge
                                            : AppTextStyles.bodyMedium)
                                        .copyWith(color: secondaryText),
                              ),
                            ),
                            Icon(
                              Icons.send_outlined,
                              size: isTablet ? 24 : 20,
                              color: secondaryText,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Individual action card widget used inside the grid.
/// This widget is PURE UI and receives all colors from parent.
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color lightBg;
  final Color secondaryText;
  final Color borderColor;
  final bool isTablet;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.lightBg,
    required this.secondaryText,
    required this.borderColor,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(isTablet ? AppSpacing.lg : AppSpacing.md),
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Icon container
          Container(
            width: isTablet ? 40 : 32,
            height: isTablet ? 40 : 32,
            decoration: BoxDecoration(
              color: lightBg,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              icon,
              size: isTablet ? 24 : 20,
              color: Theme.of(context).iconTheme.color,
            ),
          ),

          SizedBox(height: isTablet ? AppSpacing.md : AppSpacing.sm),

          /// Card title
          Text(
            title,
            style:
                (isTablet ? AppTextStyles.titleMedium : AppTextStyles.bodyLarge)
                    .copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: isTablet ? AppSpacing.xs : 4),

          /// Card description
          Text(
            description,
            style: (isTablet ? AppTextStyles.bodySmall : AppTextStyles.label)
                .copyWith(color: secondaryText),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
