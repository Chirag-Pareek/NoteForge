
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Monthly calendar widget for task tracking
/// Shows current month with date selection and task indicators
class TodoCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final List<TodoTask> tasks;
  final Function(DateTime) onDateSelected;

  const TodoCalendar({
    super.key,
    required this.selectedDate,
    required this.tasks,
    required this.onDateSelected,
  });

  /// Gets number of days in month
  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  /// Gets first day of month (0 = Monday, 6 = Sunday)
  int _getFirstDayOfMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    return (firstDay.weekday % 7);
  }

  /// Checks if date has tasks
  bool _hasTasksOnDate(DateTime date) {
    return tasks.any((task) =>
        task.date.year == date.year &&
        task.date.month == date.month &&
        task.date.day == date.day);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysInMonth = _getDaysInMonth(selectedDate);
    final firstDayOffset = _getFirstDayOfMonth(selectedDate);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.background : AppColorsLight.background,
        border: Border.all(
          color: isDark ? AppColorsDark.border : AppColorsLight.border,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Month header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: () {
                  final newDate = DateTime(
                    selectedDate.year,
                    selectedDate.month - 1,
                    1,
                  );
                  onDateSelected(newDate);
                },
              ),
              Text(
                '${_getMonthName(selectedDate.month)} ${selectedDate.year}',
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                onPressed: () {
                  final newDate = DateTime(
                    selectedDate.year,
                    selectedDate.month + 1,
                    1,
                  );
                  onDateSelected(newDate);
                },
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Weekday labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(
                          day,
                          style: AppTextStyles.label.copyWith(
                            color: isDark ? AppColorsDark.secondaryText : AppColorsLight.secondaryText,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: firstDayOffset + daysInMonth,
            itemBuilder: (context, index) {
              if (index < firstDayOffset) {
                return const SizedBox.shrink();
              }

              final day = index - firstDayOffset + 1;
              final date = DateTime(selectedDate.year, selectedDate.month, day);
              final isSelected = date.day == selectedDate.day &&
                  date.month == selectedDate.month &&
                  date.year == selectedDate.year;
              final hasTask = _hasTasksOnDate(date);

              return GestureDetector(
                onTap: () => onDateSelected(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColorsDark.primaryText : AppColorsLight.primaryText)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? (isDark ? AppColorsDark.primaryText : AppColorsLight.primaryText)
                          : Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          '$day',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isSelected
                                ? (isDark ? AppColorsDark.background : AppColorsLight.background)
                                : (isDark ? AppColorsDark.primaryText : AppColorsLight.primaryText),
                          ),
                        ),
                      ),
                      if (hasTask)
                        Positioned(
                          bottom: 4,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? AppColorsDark.background : AppColorsLight.background)
                                    : (isDark ? AppColorsDark.primaryText : AppColorsLight.primaryText),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

/// Data model for a todo task
class TodoTask {
  final String id;
  final String title;
  final DateTime date;
  bool isCompleted;

  TodoTask({
    required this.id,
    required this.title,
    required this.date,
    required this.isCompleted,
  });
}