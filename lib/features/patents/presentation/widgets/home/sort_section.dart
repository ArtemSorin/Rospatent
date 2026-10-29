import 'package:flutter/material.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';

class SortSection extends StatelessWidget {
  final SortOrder value;
  final ValueChanged<SortOrder> onChanged;

  const SortSection({super.key, required this.value, required this.onChanged});

  static const _labels = <SortOrder, String>{
    SortOrder.relevance: "Релевантности",
    SortOrder.publicationAsc: "Дате публикации ↑",
    SortOrder.publicationDesc: "Дате публикации ↓",
    SortOrder.filingAsc: "Дате регистрации ↑",
    SortOrder.filingDesc: "Дате регистрации ↓",
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Сортировка",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.sort, color: Colors.blueAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<SortOrder>(
                    value: value,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.grey.shade100,
                      filled: true,
                    ),
                    items: [
                      for (final e in _labels.entries)
                        DropdownMenuItem(value: e.key, child: Text(e.value)),
                    ],
                    onChanged: (v) {
                      if (v != null) onChanged(v);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
