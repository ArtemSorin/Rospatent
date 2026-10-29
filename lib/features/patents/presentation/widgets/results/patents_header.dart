import 'package:flutter/material.dart';

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
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Найдено патентов: $totalFound",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          if (totalPages > 1)
            Text(
              "стр. ${currentPage + 1} из $totalPages",
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
        ],
      ),
    );
  }
}
