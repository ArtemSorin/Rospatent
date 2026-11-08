import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rospatent/app/app_scope.dart';
import 'package:rospatent/core/theme/app_colors.dart';
import 'package:rospatent/core/theme/app_text.dart';
import 'package:rospatent/core/widgets/app_ui.dart';
import 'package:rospatent/core/widgets/hero_header.dart';
import 'package:rospatent/features/history/domain/entities/search_history_entry.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';
import 'package:rospatent/features/patents/presentation/screens/search_results_screen.dart';
import 'package:rospatent/features/patents/presentation/widgets/home/sort_section.dart';

import '../controllers/search_history_controller.dart';

/// История поисковых запросов: нажатие повторяет запрос.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final SearchHistoryController _controller;
  final _dateFormat = DateFormat('dd.MM.yyyy');
  final _timeFormat = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    final deps = AppScope.of(context);
    _controller = SearchHistoryController(
      getHistory: deps.getSearchHistory,
      addHistory: deps.addSearchHistory,
      removeHistory: deps.removeSearchHistory,
      clearHistory: deps.clearSearchHistory,
    )..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _repeat(SearchHistoryEntry entry) async {
    await _controller.bump(entry);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchResultsPage(query: entry.query)),
    );
    if (mounted) _controller.load();
  }

  Future<void> _remove(SearchHistoryEntry entry) async {
    await _controller.remove(entry);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Запрос удалён из истории'),
          action: SnackBarAction(
            label: 'Отменить',
            onPressed: () => _controller.restore(entry),
          ),
        ),
      );
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Очистить историю?', style: AppText.h3),
        content: const Text(
          'Все сохранённые запросы будут удалены. Избранное не изменится.',
          style: AppText.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
    if (ok == true) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final c = _controller;
        return Scaffold(
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: Column(
              children: [
                HeroHeader(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('История', style: AppText.onDarkTitle),
                            const SizedBox(height: 6),
                            Text(
                              c.items.isEmpty
                                  ? 'Ваши прошлые поиски'
                                  : 'Запросов: ${c.items.length}',
                              style: AppText.onDarkBody,
                            ),
                          ],
                        ),
                      ),
                      if (c.items.isNotEmpty)
                        HeroIconButton(
                          icon: Icons.delete_sweep_outlined,
                          tooltip: 'Очистить историю',
                          onPressed: _confirmClear,
                        ),
                    ],
                  ),
                ),
                Expanded(child: _buildBody(c)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(SearchHistoryController c) {
    if (c.loading) return const Center(child: CircularProgressIndicator());
    if (c.error != null && c.items.isEmpty) {
      return StateView(
        icon: Icons.error_outline_rounded,
        isError: true,
        title: 'Не удалось загрузить',
        subtitle: c.error,
        actionLabel: 'Повторить',
        onAction: c.load,
      );
    }
    if (c.items.isEmpty) {
      return const StateView(
        icon: Icons.history_rounded,
        title: 'История пуста',
        subtitle: 'Здесь появятся ваши поисковые запросы, чтобы их можно было повторить в одно касание',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: c.items.length,
      itemBuilder: (context, index) {
        final entry = c.items[index];
        return Dismissible(
          key: ValueKey(entry.key),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.danger,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          ),
          onDismissed: (_) => _remove(entry),
          child: _buildCard(entry),
        );
      },
    );
  }

  Widget _buildCard(SearchHistoryEntry entry) {
    final q = entry.query;
    final hasText = q.text.trim().isNotEmpty;
    final chips = <Widget>[
      if (q.sort != SortOrder.relevance)
        _chip(Icons.sort_rounded, SortSection.labels[q.sort] ?? ''),
      if (q.publishedFrom != null)
        _chip(Icons.calendar_today_outlined, 'с ${_dateFormat.format(q.publishedFrom!)}'),
      if (q.publishedTo != null)
        _chip(Icons.calendar_today_outlined, 'по ${_dateFormat.format(q.publishedTo!)}'),
      if (q.authors.isNotEmpty)
        _chip(Icons.person_outline_rounded, 'Автор: ${q.authors.join(', ')}'),
      if (q.patentees.isNotEmpty)
        _chip(Icons.business_outlined, q.patentees.join(', ')),
    ];

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      onTap: () => _repeat(entry),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.brandSoft,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.search_rounded, color: AppColors.brand, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      hasText ? q.text.trim() : 'Без текста запроса',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: hasText ? AppColors.ink : AppColors.inkSecondary,
                      ),
                    ),
                  ),
                  if (chips.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(spacing: 6, runSpacing: 6, children: chips),
                  ],
                  const SizedBox(height: 8),
                  Text(_when(entry.searchedAt), style: AppText.caption),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Удалить из истории',
              icon: const Icon(Icons.close_rounded, size: 20),
              color: AppColors.inkTertiary,
              onPressed: () => _remove(entry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) => AppTag(
    label,
    icon: icon,
    background: AppColors.bg,
    foreground: AppColors.inkSecondary,
  );

  String _when(DateTime at) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(at.year, at.month, at.day);
    final diff = today.difference(day).inDays;
    final time = _timeFormat.format(at);
    if (diff == 0) return 'Сегодня, $time';
    if (diff == 1) return 'Вчера, $time';
    return '${_dateFormat.format(at)}, $time';
  }
}
