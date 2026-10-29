import 'package:flutter/material.dart';
import 'package:rospatent/app/app_scope.dart';
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
          backgroundColor: Colors.grey.shade100,
          appBar: CustomAppBar(
            title: "Найденные патенты",
            centerTitle: true,
            leading: IconButton(
              color: Colors.blueAccent,
              icon: const Icon(Icons.arrow_back_ios),
              tooltip: 'Назад',
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                color: Colors.blueAccent,
                tooltip: 'Анализировать результаты',
                icon: const Icon(Icons.data_usage_outlined),
                onPressed: page == null ? null : () => _openAnalytics(page),
              ),
            ],
          ),
          bottomNavigationBar: page == null
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
        return _MessageView(
          icon: Icons.error_outline,
          text: _controller.error!,
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
          const LinearProgressIndicator(minHeight: 2)
        else
          const SizedBox(height: 2),
        if (_controller.error != null)
          _ErrorBanner(message: _controller.error!, onRetry: _controller.retry),
        Expanded(
          child: page.items.isEmpty
              ? const _MessageView(
                  icon: Icons.search_off,
                  text: 'По вашему запросу ничего не найдено',
                )
              : ListView.builder(
                  controller: _scroll,
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

class _MessageView extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageView({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
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
      color: Colors.red.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 13))),
          TextButton(onPressed: onRetry, child: const Text('Повторить')),
        ],
      ),
    );
  }
}
