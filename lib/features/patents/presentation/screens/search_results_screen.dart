import 'package:flutter/material.dart';
import 'package:rospatent/app/app_scope.dart';
import 'package:rospatent/core/theme/app_colors.dart';
import 'package:rospatent/core/widgets/app_ui.dart';
import 'package:rospatent/core/widgets/custom_app_bar.dart';
import 'package:rospatent/core/widgets/page_paginator.dart';
import 'package:rospatent/features/analytics/presentation/screens/analyze_screen.dart';
import 'package:rospatent/features/patents/domain/entities/search_page.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';

import '../controllers/search_results_controller.dart';
import '../widgets/results/patent_card.dart';
import '../widgets/results/patents_header.dart';
import 'patent_details_screen.dart';

class SearchResultsPage extends StatefulWidget {
  final SearchQuery query;
  const SearchResultsPage({super.key, required this.query});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late final SearchResultsController _controller;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = SearchResultsController(
      searchPatents: AppScope.of(context).searchPatents,
      query: widget.query,
    )..load(0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _goToPage(int index) async {
    await _controller.load(index);
    if (mounted && _controller.error == null && _scroll.hasClients) {
      _scroll.jumpTo(0);
    }
  }

  void _openAnalytics(SearchPage page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalyzePage(
          query: widget.query,
          pageItems: page.items,
          totalFound: page.total,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final page = _controller.page;
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Найденные патенты',
            leading: const AppBackButton(),
            actions: [
              AppBarButton(
                tooltip: 'Анализировать результаты',
                icon: Icons.bar_chart_rounded,
                onPressed: page == null ? null : () => _openAnalytics(page),
              ),
            ],
          ),
          bottomNavigationBar: page == null || _controller.totalPages <= 1
              ? null
              : PagePaginator(
                  currentPage: _controller.currentPage,
                  totalPages: _controller.totalPages,
                  enabled: !_controller.loading,
                  onPageSelected: _goToPage,
                ),
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    final page = _controller.page;

    if (page == null) {
      if (_controller.error != null) {
        return StateView(
          icon: Icons.wifi_off_rounded,
          isError: true,
          title: 'Не удалось загрузить',
          subtitle: _controller.error!,
          actionLabel: 'Повторить',
          onAction: _controller.retry,
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PatentsHeader(
          totalFound: page.total,
          currentPage: _controller.currentPage,
          totalPages: _controller.totalPages,
        ),
        if (_controller.loading)
          const LinearProgressIndicator(minHeight: 3)
        else
          const SizedBox(height: 3),
        if (_controller.error != null)
          _ErrorBanner(message: _controller.error!, onRetry: _controller.retry),
        Expanded(
          child: page.items.isEmpty
              ? const StateView(
                  icon: Icons.search_off_rounded,
                  title: 'Ничего не найдено',
                  subtitle: 'Попробуйте изменить запрос или расширить период',
                )
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: page.items.length,
                  itemBuilder: (context, index) {
                    final patent = page.items[index];
                    return PatentCard(
                      patent: patent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PatentDetailsPage(
                            patentId: patent.id,
                            hint: patent,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 20, color: AppColors.danger),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 13))),
          TextButton(onPressed: onRetry, child: const Text('Повторить')),
        ],
      ),
    );
  }
}
