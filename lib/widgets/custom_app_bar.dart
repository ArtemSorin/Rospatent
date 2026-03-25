import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Color backgroundColor;
  final double elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.centerTitle = false,
    this.leading,
    this.actions,
    this.backgroundColor = Colors.white,
    this.elevation = 1,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
    );
  }
}
