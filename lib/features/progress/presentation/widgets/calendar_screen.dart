import 'package:flutter/material.dart';
import 'package:noteforge/core/theme/app_colors.dart';
import 'package:noteforge/core/theme/app_spacing.dart';
import 'package:noteforge/core/theme/app_text_styles.dart';
import 'package:noteforge/features/progress/presentation/widgets/todo_calendar.dart';

/// Calendar screen showing monthly view with study tasks
/// Allows adding, editing, and completing tasks
class CalendarScreen extends StatefulWidget {
  final double topPadding;

  const CalendarScreen({super.key, required this.topPadding});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<TodoTask> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadDemoTasks();
  }

  /// Loads demo tasks (in production, fetch from local storage)
  void _loadDemoTasks() {
    final today = DateTime.now();
    _tasks
      ..clear()
      ..addAll([
        TodoTask(
          id: '1',
          title: 'Complete Physics Chapter 12',
          date: today,
          isCompleted: false,
        ),
        TodoTask(
          id: '2',
          title: 'Math Practice Set 5',
          date: today,
          isCompleted: true,
        ),
        TodoTask(
          id: '3',
          title: 'Chemistry Lab Report',
          date: today.add(const Duration(days: 1)),
          isCompleted: false,
        ),
      ]);
  }

  /// Handles adding a new task
  void _addTask() {
    showDialog(
      context: context,
      builder: (context) => _AddTaskDialog(
        selectedDate: _selectedDate,
        onTaskAdded: (task) {
          setState(() {
            _tasks.add(task);
          });
        },
      ),
    );
  }

  /// Toggles task completion
  void _toggleTaskCompletion(String taskId) {
    setState(() {
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex == -1) {
        return;
      }
      _tasks[taskIndex].isCompleted = !_tasks[taskIndex].isCompleted;
    });
  }

  /// Gets tasks for selected date
  List<TodoTask> _getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      return task.date.year == date.year &&
          task.date.month == date.month &&
          task.date.day == date.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tasksForSelectedDate = _getTasksForDate(_selectedDate);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        widget.topPadding,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar widget
          TodoCalendar(
            selectedDate: _selectedDate,
            tasks: _tasks,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // Tasks section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tasks for ${_selectedDate.day}/${_selectedDate.month}',
                style: AppTextStyles.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: _addTask,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Task list
          if (tasksForSelectedDate.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'No tasks for this day',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColorsDark.secondaryText
                        : AppColorsLight.secondaryText,
                  ),
                ),
              ),
            )
          else
            ...tasksForSelectedDate.map(
              (task) => _buildTaskItem(context, task),
            ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  /// Builds a single task item
  Widget _buildTaskItem(BuildContext context, TodoTask task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.background : AppColorsLight.background,
          border: Border.all(
            color: isDark ? AppColorsDark.border : AppColorsLight.border,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _toggleTaskCompletion(task.id),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? (isDark
                            ? AppColorsDark.primaryText
                            : AppColorsLight.primaryText)
                      : Colors.transparent,
                  border: Border.all(
                    color: isDark
                        ? AppColorsDark.border
                        : AppColorsLight.border,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: task.isCompleted
                    ? Icon(
                        Icons.check,
                        size: 14,
                        color: isDark
                            ? AppColorsDark.background
                            : AppColorsLight.background,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                task.title,
                style: AppTextStyles.bodyMedium.copyWith(
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: task.isCompleted
                      ? (isDark
                            ? AppColorsDark.secondaryText
                            : AppColorsLight.secondaryText)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for adding a new task
class _AddTaskDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Function(TodoTask) onTaskAdded;

  const _AddTaskDialog({required this.selectedDate, required this.onTaskAdded});

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: 'Enter task title'),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              final task = TodoTask(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: _controller.text.trim(),
                date: widget.selectedDate,
                isCompleted: false,
              );
              widget.onTaskAdded(task);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
