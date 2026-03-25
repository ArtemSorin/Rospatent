import 'package:flutter/material.dart';

class PatentsHeader extends StatelessWidget {
  final int totalFound;

  const PatentsHeader({super.key, required this.totalFound});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        "Найдено патентов: $totalFound",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
