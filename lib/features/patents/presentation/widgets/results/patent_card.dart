import 'package:flutter/material.dart';
import 'package:rospatent/core/theme/app_colors.dart';
import 'package:rospatent/core/widgets/app_ui.dart';
import 'package:rospatent/features/patents/domain/entities/patent_summary.dart';
import 'package:tag_highlight_text/tag_highlight_text.dart';

class PatentCard extends StatelessWidget {
  final PatentSummary patent;
  final VoidCallback onTap;

  const PatentCard({super.key, required this.patent, required this.onTap});

  /// Найденное слово — мягкая синяя подложка и синий жирный текст
  /// (читается лучше, чем белый на сплошной синей «таблетке»).
  HighlightData? _highlight(String tagName, {required bool bold, required double size}) {
    if (tagName != 'em') return null;
    return HighlightData(
      builder: (text) => WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.brandSofter,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: size,
              color: AppColors.brand,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = patent.lang.trim();
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (lang.isNotEmpty) ...[
                  AppTag(lang.toUpperCase(), icon: Icons.translate_rounded),
                  const SizedBox(height: 10),
                ],
                TagHighlightText(
                  text: patent.title,
                  highlightBuilder: (tag) => _highlight(tag, bold: true, size: 16.5),
                  textStyle: const TextStyle(
                    fontSize: 16.5,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                TagHighlightText(
                  text: patent.description,
                  highlightBuilder: (tag) => _highlight(tag, bold: false, size: 14),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.inkSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                _row(Icons.person_outline_rounded, 'Автор', patent.inventors),
                _row(Icons.category_outlined, 'МПК', patent.ipc),
              ],
            ),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Открыть патент',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brand,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.brand),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.inkTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(color: AppColors.inkSecondary),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
