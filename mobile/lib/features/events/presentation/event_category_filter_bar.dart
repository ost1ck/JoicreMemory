import 'package:flutter/material.dart';

import '../data/event_category.dart';

class EventCategoryFilterBar extends StatelessWidget {
  const EventCategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  final String? selectedCategory;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: eventCategories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return FilterChip(
              label: const Text('Усі'),
              selected: selectedCategory == null,
              onSelected: (_) => onChanged(null),
            );
          }

          final category = eventCategories[index - 1];

          return FilterChip(
            label: Text(category.label),
            selected: selectedCategory == category.value,
            onSelected: (_) => onChanged(category.value),
          );
        },
      ),
    );
  }
}
