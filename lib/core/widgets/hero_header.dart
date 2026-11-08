import 'package:flutter/material.dart';
import 'package:rospatent/core/theme/app_colors.dart';

/// Синяя шапка с декоративными фигурами (круги и скруглённый квадрат) —
/// фирменный приём госприложений: заголовок крупно слева, фигуры на фоне.
///
/// Для шапки экрана — по умолчанию (скруглены нижние углы, учитывается
/// статус-бар). Для баннера внутри экрана — [borderRadius] со всеми углами
/// и `safeTop: false`.
class HeroHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final bool safeTop;

  const HeroHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 24),
    this.borderRadius = const BorderRadius.vertical(
      bottom: Radius.circular(28),
    ),
    this.safeTop = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding, child: child);
    if (safeTop) content = SafeArea(bottom: false, child: content);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandBright, AppColors.brand, AppColors.brandDark],
          stops: [0, 0.55, 1],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: IgnorePointer(child: _HeroShapes())),
          content,
        ],
      ),
    );
  }
}

class _HeroShapes extends StatelessWidget {
  const _HeroShapes();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: -70,
          top: -64,
          child: _circle(220, AppColors.heroShapeDark),
        ),
        Positioned(
          left: -56,
          top: -78,
          child: _circle(150, AppColors.heroShapeLight),
        ),
        Positioned(
          right: 36,
          bottom: -34,
          child: Transform.rotate(
            angle: 0.6,
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.heroShapeLight,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Кнопка-иконка на синем фоне («стеклянная»).
class HeroIconButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onPressed;

  const HeroIconButton({
    super.key,
    required this.icon,
    this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: AppColors.onHeroGlass,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 22, color: Colors.white),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
