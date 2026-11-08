import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rospatent/core/theme/app_colors.dart';
import 'package:rospatent/core/theme/app_text.dart';

/// Белая шапка внутренних экранов: кнопки в мягких скруглённых квадратах,
/// заголовок по центру, тонкая линия снизу.
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
    this.centerTitle = true,
    this.leading,
    this.actions,
    this.backgroundColor = Colors.white,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: elevation,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: centerTitle,
      leading: leading,
      leadingWidth: leading == null ? null : 60,
      title: Text(title, style: AppText.h3),
      actions: [...?actions, const SizedBox(width: 4)],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppColors.line),
      ),
    );
  }
}

/// Квадратная кнопка для шапки: «назад», «в избранное», «аналитика».
class AppBarButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? background;

  const AppBarButton({
    super.key,
    required this.icon,
    this.tooltip,
    this.onPressed,
    this.color,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final button = Material(
      color: enabled
          ? (background ?? AppColors.brandSoft)
          : AppColors.bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 20,
            color: enabled ? (color ?? AppColors.brand) : AppColors.inkTertiary,
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: tooltip == null
          ? button
          : Tooltip(message: tooltip!, child: button),
    );
  }
}

/// Кнопка «назад» для внутренних экранов.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBarButton(
      icon: Icons.arrow_back_ios_new_rounded,
      tooltip: 'Назад',
      onPressed: () => Navigator.maybePop(context),
    );
  }
}
