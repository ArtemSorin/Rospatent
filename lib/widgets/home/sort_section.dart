import 'package:flutter/material.dart';

class SortSection extends StatelessWidget {
  final int sortValue;
  final ValueChanged<int> onChanged;

  const SortSection({
    super.key,
    required this.sortValue,
    required this.onChanged,
  });

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
                  child: DropdownButtonFormField<int>(
                    initialValue: sortValue,
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
                    items: const [
                      DropdownMenuItem(value: 1, child: Text("Релевантности")),
                      DropdownMenuItem(
                        value: 2,
                        child: Text("Дате публикации ↑"),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text("Дате публикации ↓"),
                      ),
                      DropdownMenuItem(
                        value: 4,
                        child: Text("Дате регистрации ↑"),
                      ),
                      DropdownMenuItem(
                        value: 5,
                        child: Text("Дате регистрации ↓"),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) onChanged(val);
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
