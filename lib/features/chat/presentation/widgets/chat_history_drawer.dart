import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';

class ChatHistoryItem {
  final String id;
  final String title;
  final DateTime date;

  const ChatHistoryItem({
    required this.id,
    required this.title,
    required this.date,
  });
}

class ChatHistoryDrawer extends StatelessWidget {
  final List<ChatHistoryItem> items;
  final String? selectedId;
  final String searchQuery;
  // Drawer behavior: selecting an item loads that chat in the parent screen.
  final ValueChanged<ChatHistoryItem> onSelect;
  final ValueChanged<String> onSearchChanged;

  const ChatHistoryDrawer({
    super.key,
    required this.items,
    required this.onSelect,
    required this.onSearchChanged,
    required this.searchQuery,
    this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = items.where((item) {
      if (searchQuery.isEmpty) {
        return true;
      }
      return item.title.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    final today = DateTime.now();
    final yesterday = DateTime(today.year, today.month, today.day - 1);

    final todayItems = filtered.where((i) => _isSameDay(i.date, today)).toList();
    final yesterdayItems =
        filtered.where((i) => _isSameDay(i.date, yesterday)).toList();
    final olderItems = filtered
        .where((i) => i.date.isBefore(DateTime(yesterday.year, yesterday.month, yesterday.day)))
        .toList();

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            AppTextField(
              hintText: 'Search',
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (todayItems.isNotEmpty) ...[
              Text('Today', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              ..._buildItems(context, todayItems, selectedId),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (yesterdayItems.isNotEmpty) ...[
              Text('Yesterday', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              ..._buildItems(context, yesterdayItems, selectedId),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (olderItems.isNotEmpty) ...[
              Text('Older', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              ..._buildItems(context, olderItems, selectedId),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItems(
    BuildContext context,
    List<ChatHistoryItem> items,
    String? selectedId,
  ) {
    return items
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppCard(
              onTap: () {
                Navigator.of(context).pop();
                onSelect(item);
              },
              child: Text(item.title, style: AppTextStyles.bodyMedium),
            ),
          ),
        )
        .toList();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
