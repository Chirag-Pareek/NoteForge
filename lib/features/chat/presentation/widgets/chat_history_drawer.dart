// lib/features/chat/presentation/widgets/chat_history_drawer.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../chat_with_ai_screen.dart';

/// Left drawer showing chat history organized by date
class ChatHistoryDrawer extends StatefulWidget {
  final List<ChatHistory> chatHistories;
  final Function(ChatHistory) onChatSelected;
  final Function(String) onDeleteChat;

  const ChatHistoryDrawer({
    super.key,
    required this.chatHistories,
    required this.onChatSelected,
    required this.onDeleteChat,
  });

  @override
  State<ChatHistoryDrawer> createState() => _ChatHistoryDrawerState();
}

class _ChatHistoryDrawerState extends State<ChatHistoryDrawer> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter histories by search query
    final filteredHistories = widget.chatHistories.where((history) {
      return history.topic.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Group histories by date
    final groupedHistories = _groupHistoriesByDate(filteredHistories);

    return Drawer(
      backgroundColor: isDark ? AppColorsDark.background : AppColorsLight.background,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer header with search
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'History',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Search bar
                  AppTextField(
                    hintText: 'Search',
            
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // History list
            Expanded(
              child: filteredHistories.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      itemCount: groupedHistories.length,
                      itemBuilder: (context, index) {
                        final group = groupedHistories[index];
                        return _buildDateGroup(
                          context,
                          group.dateLabel,
                          group.histories,
                          isDark,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a date group with its history items
  Widget _buildDateGroup(
    BuildContext context,
    String dateLabel,
    List<ChatHistory> histories,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date label
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Text(
            dateLabel,
            style: AppTextStyles.label.copyWith(
              color: isDark ? AppColorsDark.secondaryText : AppColorsLight.secondaryText,
            ),
          ),
        ),

        // History items
        ...histories.map((history) => _buildHistoryItem(context, history, isDark)),
      ],
    );
  }

  /// Builds a single history item card
  Widget _buildHistoryItem(BuildContext context, ChatHistory history, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => widget.onChatSelected(history),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColorsDark.background : AppColorsLight.background,
            border: Border.all(
              color: isDark ? AppColorsDark.border : AppColorsLight.border,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  history.topic,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              
              // Delete button
              InkWell(
                onTap: () => _confirmDelete(context, history),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: isDark ? AppColorsDark.secondaryText : AppColorsLight.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Empty state when no history
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: isDark ? AppColorsDark.border : AppColorsLight.border,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _searchQuery.isEmpty ? 'No chat history yet' : 'No results found',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColorsDark.secondaryText : AppColorsLight.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Confirms deletion of a chat history item
  void _confirmDelete(BuildContext context, ChatHistory history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete chat'),
        content: const Text('Are you sure you want to delete this chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onDeleteChat(history.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Groups chat histories by date (Today, Yesterday, specific dates)
  List<DateGroup> _groupHistoriesByDate(List<ChatHistory> histories) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<ChatHistory>> grouped = {};

    for (final history in histories) {
      final date = DateTime(
        history.date.year,
        history.date.month,
        history.date.day,
      );

      String label;
      if (date == today) {
        label = 'Today';
      } else if (date == yesterday) {
        label = 'Yesterday';
      } else {
        label = '${date.day} ${_getMonthName(date.month)} ${date.year}';
      }

      grouped[label] ??= [];
      grouped[label]!.add(history);
    }

    // Sort groups: Today, Yesterday, then by date descending
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        if (a == 'Today') return -1;
        if (b == 'Today') return 1;
        if (a == 'Yesterday') return -1;
        if (b == 'Yesterday') return 1;
        return b.compareTo(a);
      });

    return sortedKeys.map((label) {
      return DateGroup(dateLabel: label, histories: grouped[label]!);
    }).toList();
  }

  /// Returns month name for a given month number
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

/// Data model for grouped date section
class DateGroup {
  final String dateLabel;
  final List<ChatHistory> histories;

  DateGroup({
    required this.dateLabel,
    required this.histories,
  });
}