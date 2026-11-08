import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rospatent/core/theme/app_colors.dart';
import 'package:rospatent/features/about/presentation/about_screen.dart';
import 'package:rospatent/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:rospatent/features/history/presentation/screens/history_screen.dart';
import 'package:rospatent/features/patents/presentation/screens/home_screen.dart';

/// Главная оболочка с нижней навигацией между разделами.
/// Экран подменяется целиком, поэтому «История» и «Избранное»
/// перезагружаются при каждом входе.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = <Widget>[
    HomePage(),
    HistoryPage(),
    FavoritePage(),
    AboutPage(),
  ];

  static const _items = <_NavItem>[
    _NavItem('Поиск', Icons.search_rounded, Icons.search_rounded),
    _NavItem('История', Icons.history_rounded, Icons.history_rounded),
    _NavItem('Избранное', Icons.star_outline_rounded, Icons.star_rounded),
    _NavItem('О приложении', Icons.info_outline_rounded, Icons.info_rounded),
  ];

  void _select(int i) {
    if (i == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: _FloatingBar(
        index: _index,
        items: _items,
        onTap: _select,
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItem(this.label, this.icon, this.activeIcon);
}

/// Плавающая «капсула»: белая, со скруглением и мягкой тенью.
/// Активный раздел раскрывается синей таблеткой с подписью,
/// остальные показывают только иконки.
class _FloatingBar extends StatelessWidget {
  final int index;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _FloatingBar({
    required this.index,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.line),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F0B1F35),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Color(0x0F0B1F35),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          // высота задана явно: иначе Center внутри Expanded растягивает
          // панель на всю высоту экрана
          child: SizedBox(
            height: 48,
            child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                i == index
                    ? _BarItem(item: items[i], selected: true, onTap: () => onTap(i))
                    : Expanded(
                        child: Center(
                          child: _BarItem(
                            item: items[i],
                            selected: false,
                            onTap: () => onTap(i),
                          ),
                        ),
                      ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _BarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: selected ? 18 : 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.brand : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? item.activeIcon : item.icon,
                size: 24,
                color: selected ? Colors.white : AppColors.inkSecondary,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                alignment: Alignment.centerLeft,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          item.label,
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
