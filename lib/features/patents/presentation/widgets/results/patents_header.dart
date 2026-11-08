import 'package:flutter/material.dart';
import 'package:rospatent/core/theme/app_text.dart';
import 'package:rospatent/core/utils/text_utils.dart';
import 'package:rospatent/core/widgets/app_ui.dart';

class PatentsHeader extends StatelessWidget {
  final int totalFound;
  final int currentPage; // с 0
  final int totalPages;

  const PatentsHeader({
    super.key,
    required this.totalFound,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Найдено патентов', style: AppText.caption),
                const SizedBox(height: 2),
                Text(formatInt(totalFound), style: AppText.h2),
              ],
            ),
          ),
          if (totalPages > 1)
            AppTag('стр. ${currentPage + 1} из ${formatInt(totalPages)}'),
        ],
      ),
    );
  }
}
