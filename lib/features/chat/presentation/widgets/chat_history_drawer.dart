// lib/features/chat/presentation/widgets/chat_history_drawer.dart

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_effects.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../chat_with_ai_screen.dart';

/// Left drawer showing chat history organized by recency buckets.
class ChatHistoryDrawer extends StatefulWidget {
  final List<ChatHistory> chatHistories;
  final ValueChanged<ChatHistory> onChatSelected;
  final ValueChanged<String> onDeleteChat;

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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _animateIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _animateIn = true;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredHistories = widget.chatHistories.where((history) {
      return history.topic.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList()..sort((a, b) => b.date.compareTo(a.date));

    final groupedHistories = _groupHistoriesByDate(filteredHistories);

    return Drawer(
      backgroundColor: isDark
          ? AppColorsDark.background
          : AppColorsLight.background,
      child: SafeArea(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: _animateIn ? 1 : 0),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(-18 * (1 - value), 0),
                child: child,
              ),
            );
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth < 340
                  ? AppSpacing.md
                  : AppSpacing.lg;

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      AppSpacing.lg,
                      horizontalPadding,
                      AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('History', style: AppTextStyles.titleMedium),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          hintText: 'Search chats',
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          suffixIcon: _searchQuery.isEmpty
                              ? const Icon(Icons.search)
                              : IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: filteredHistories.isEmpty
                          ? _buildEmptyState(isDark)
                          : ListView.builder(
                              key: ValueKey<int>(filteredHistories.length),
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
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
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDateGroup(
    BuildContext context,
    String dateLabel,
    List<ChatHistory> histories,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              dateLabel,
              style: AppTextStyles.label.copyWith(
                color: isDark
                    ? AppColorsDark.secondaryText
                    : AppColorsLight.secondaryText,
              ),
            ),
          ),
          ...histories.map(
            (history) => _buildHistoryItem(context, history, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    ChatHistory history,
    bool isDark,
  ) {
    final timeLabel = _buildItemTimeLabel(history.date);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => widget.onChatSelected(history),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? AppColorsDark.background
                : AppColorsLight.background,
            border: Border.all(
              color: isDark ? AppColorsDark.border : AppColorsLight.border,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppEffects.subtleDepth(Theme.of(context).brightness),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.topic,
                      style: AppTextStyles.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      timeLabel,
                      style: AppTextStyles.label.copyWith(
                        color: isDark
                            ? AppColorsDark.secondaryText
                            : AppColorsLight.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _confirmDelete(context, history),
                icon: Icon(
                  Icons.close,
                  size: 16,
                  color: isDark
                      ? AppColorsDark.secondaryText
                      : AppColorsLight.secondaryText,
                ),
                splashRadius: AppSpacing.xl,
                tooltip: 'Delete chat',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      key: ValueKey<String>(_searchQuery),
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
                color: isDark
                    ? AppColorsDark.secondaryText
                    : AppColorsLight.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

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

  List<DateGroup> _groupHistoriesByDate(List<ChatHistory> histories) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    final todayItems = <ChatHistory>[];
    final thisWeekItems = <ChatHistory>[];
    final earlierItems = <ChatHistory>[];

    for (final history in histories) {
      final date = DateTime(
        history.date.year,
        history.date.month,
        history.date.day,
      );
      if (date == today) {
        todayItems.add(history);
      } else if (!date.isBefore(weekStart)) {
        thisWeekItems.add(history);
      } else {
        earlierItems.add(history);
      }
    }

    final groups = <DateGroup>[];
    if (todayItems.isNotEmpty) {
      groups.add(DateGroup(dateLabel: 'Today', histories: todayItems));
    }
    if (thisWeekItems.isNotEmpty) {
      groups.add(DateGroup(dateLabel: 'This week', histories: thisWeekItems));
    }
    if (earlierItems.isNotEmpty) {
      groups.add(DateGroup(dateLabel: 'Earlier', histories: earlierItems));
    }
    return groups;
  }

  String _buildItemTimeLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);
    final time = TimeOfDay.fromDateTime(date).format(context);

    if (itemDate == today) {
      return time;
    }

    final shortDate = '${date.day}/${date.month}/${date.year}';
    return '$shortDate • $time';
  }
}

class DateGroup {
  final String dateLabel;
  final List<ChatHistory> histories;

  DateGroup({required this.dateLabel, required this.histories});
}
