import 'package:flutter/material.dart';

class BottomNavPagination extends StatelessWidget {
  final int currentIndex;
  final List<BottomNavigationBarItem> items;
  final void Function(int) onTap;

  const BottomNavPagination({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.blueAccent,
      items: items,
    );
  }
}
