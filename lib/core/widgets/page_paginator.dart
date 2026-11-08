import 'package:flutter/material.dart';
import 'package:rospatent/core/theme/app_colors.dart';
import 'package:rospatent/core/theme/app_text.dart';

/// Какие элементы показывать в пагинаторе: номера страниц (с 0) и null — «…».
/// Всегда не больше 7 элементов, поэтому влезает на любой экран, даже если
/// страниц десятки тысяч.
List<int?> paginatorItems(int current, int total) {
  if (total <= 0) return const [];
  if (total <= 7) return List<int?>.generate(total, (i) => i);
  final last = total - 1;
  if (current < 4) return [0, 1, 2, 3, 4, null, last];
  if (current > last - 4) return [0, null, last - 4, last - 3, last - 2, last - 1, last];
  return [0, null, current - 1, current, current + 1, null, last];
}

/// Нижняя панель выбора страницы: « ‹  1 … 4 [5] 6 … 20  › ».
/// Нажатие на «…» открывает диалог «Перейти на страницу».
class PagePaginator extends StatelessWidget {
  /// Текущая страница, нумерация с 0.
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageSelected;

  /// false — пока грузится страница: нажатия блокируются.
  final bool enabled;

  const PagePaginator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final items = paginatorItems(currentPage, totalPages);
    final canGoBack = enabled && currentPage > 0;
    final canGoForward = enabled && currentPage < totalPages - 1;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ArrowButton(
                  icon: Icons.chevron_left_rounded,
                  tooltip: 'Предыдущая страница',
                  onPressed: canGoBack ? () => onPageSelected(currentPage - 1) : null,
                ),
                const SizedBox(width: 6),
                for (final item in items)
                  item == null
                      ? _PageButton(
                          label: '…',
                          selected: false,
                          onPressed: enabled ? () => _askPage(context) : null,
                        )
                      : _PageButton(
                          label: '${item + 1}',
                          selected: item == currentPage,
                          onPressed: enabled && item != currentPage
                              ? () => onPageSelected(item)
                              : null,
                        ),
                const SizedBox(width: 6),
                _ArrowButton(
                  icon: Icons.chevron_right_rounded,
                  tooltip: 'Следующая страница',
                  onPressed: canGoForward ? () => onPageSelected(currentPage + 1) : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _askPage(BuildContext context) async {
    final controller = TextEditingController();
    final page = await showDialog<int>(
      context: context,
      builder: (context) {
        void submit() {
          final value = int.tryParse(controller.text.trim());
          if (value != null) {
            Navigator.pop(context, value.clamp(1, totalPages).toInt() - 1);
          }
        }

        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Перейти на страницу', style: AppText.h3),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'от 1 до $totalPages'),
            onSubmitted: (_) => submit(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: submit,
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
              child: const Text('Перейти'),
            ),
          ],
        );
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
    if (page != null && page != currentPage) onPageSelected(page);
  }
}

class _PageButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  const _PageButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: selected ? AppColors.brand : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _ArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: enabled ? AppColors.brandSoft : AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              icon,
              size: 26,
              color: enabled ? AppColors.brand : const Color(0xFFB7C1D1),
            ),
          ),
        ),
      ),
    );
  }
}
