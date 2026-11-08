import 'package:flutter/material.dart';
import 'package:rospatent/core/widgets/app_ui.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';

/// Сортировка — горизонтальная лента чипов вместо выпадающего списка.
class SortSection extends StatelessWidget {
  final SortOrder value;
  final ValueChanged<SortOrder> onChanged;

  const SortSection({super.key, required this.value, required this.onChanged});

  static const labels = <SortOrder, String>{
    SortOrder.relevance: 'По релевантности',
    SortOrder.publicationAsc: 'Публикация ↑',
    SortOrder.publicationDesc: 'Публикация ↓',
    SortOrder.filingAsc: 'Регистрация ↑',
    SortOrder.filingDesc: 'Регистрация ↓',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          'Сортировка',
          caption: '↑ сначала старые, ↓ сначала новые',
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
        ),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: labels.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final entry = labels.entries.elementAt(i);
              return AppChoiceChip(
                label: entry.value,
                selected: entry.key == value,
                onTap: () => onChanged(entry.key),
              );
            },
          ),
        ),
      ],
    );
  }
}
