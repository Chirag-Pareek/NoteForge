import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/app_card.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../../core/responsive/app_breakpoints.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Step 5: Controller instantiated in State, not UI build
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final lightBg = isDark
        ? AppColorsDark.lightBackground
        : AppColorsLight.lightBackground;

    // Step 2: Use LayoutBuilder for responsiveness
    return LayoutBuilder(
      builder: (context, constraints) {
        // Step 6: Use centralized breakpoints
        final width = constraints.maxWidth;
        final isTablet = !AppBreakpoints.isMobile(width); // > 600
        final isLargeTablet = AppBreakpoints.isDesktop(width); // > 900

        // Responsive sizing
        final horizontalPadding = isTablet ? AppSpacing.xxl * 2 : AppSpacing.lg;
        final gridColumns = isLargeTablet ? 4 : (isTablet ? 3 : 2);
        final titleFontSize = isLargeTablet ? 56.0 : (isTablet ? 48.0 : null);

        // Step 4: Pure Content Screen (No Navigation Shell)
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: const SizedBox(),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: Text(
              'NoteForge',
              style:
                  (isTablet ? AppTextStyles.display : AppTextStyles.bodyLarge)
                      .copyWith(fontWeight: FontWeight.w800),
            ),
          ),
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

                      // Hero Title
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

                      // Action Grid (Responsive)
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

                      // Input Bar
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Flexible(
            child: Text(
              title,
              style:
                  (isTablet
                          ? AppTextStyles.titleMedium
                          : AppTextStyles.bodyLarge)
                      .copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: isTablet ? AppSpacing.xs : 4),
          Flexible(
            child: Text(
              description,
              style: (isTablet ? AppTextStyles.bodySmall : AppTextStyles.label)
                  .copyWith(color: secondaryText),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
