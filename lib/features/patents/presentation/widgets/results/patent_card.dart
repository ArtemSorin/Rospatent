import 'package:flutter/material.dart';
import 'package:rospatent/features/patents/domain/entities/patent_summary.dart';
import 'package:tag_highlight_text/tag_highlight_text.dart';

class PatentCard extends StatelessWidget {
  final PatentSummary patent;
  final VoidCallback onTap;

  const PatentCard({super.key, required this.patent, required this.onTap});

  HighlightData? _highlight(String tagName, {required bool bold}) {
    if (tagName != 'em') return null;
    return HighlightData(
      builder: (text) => WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TagHighlightText(
                text: patent.title,
                highlightBuilder: (tag) => _highlight(tag, bold: true),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TagHighlightText(
                text: patent.description,
                highlightBuilder: (tag) => _highlight(tag, bold: false),
                textStyle: const TextStyle(fontSize: 14, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              _row(Icons.person_outline, 'Автор', patent.inventors),
              _row(Icons.language_outlined, 'Язык', patent.lang),
              _row(Icons.category_outlined, 'МПК', patent.ipc),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
