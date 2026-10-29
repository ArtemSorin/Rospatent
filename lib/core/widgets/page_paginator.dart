import 'package:flutter/material.dart';

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

    return Material(
      color: Colors.white,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ArrowButton(
                  icon: Icons.chevron_left,
                  tooltip: 'Предыдущая страница',
                  onPressed: canGoBack ? () => onPageSelected(currentPage - 1) : null,
                ),
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
                _ArrowButton(
                  icon: Icons.chevron_right,
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
          title: const Text('Перейти на страницу'),
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
            TextButton(onPressed: submit, child: const Text('Перейти')),
          ],
        );
      },
    );
    controller.dispose();
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
    final color = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: selected ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Container(
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : Colors.black87,
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
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      color: Theme.of(context).colorScheme.primary,
      onPressed: onPressed,
    );
  }
}
