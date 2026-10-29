import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rospatent/app/app_scope.dart';
import 'package:rospatent/core/widgets/custom_app_bar.dart';
import 'package:rospatent/features/favorites/domain/entities/favorite_patent.dart';
import 'package:rospatent/features/patents/domain/entities/document_kind.dart';
import 'package:rospatent/features/patents/presentation/screens/patent_details_screen.dart';

import '../controllers/favorites_controller.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late final FavoritesController _controller;
  final _dateFormat = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    final deps = AppScope.of(context);
    _controller = FavoritesController(
      getFavorites: deps.getFavorites,
      removeFavorite: deps.removeFavorite,
      restoreFavorite: deps.restoreFavorite,
    )..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _remove(FavoritePatent item) async {
    await _controller.remove(item);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Удалено из избранного'),
          action: SnackBarAction(
            label: 'Отменить',
            onPressed: () => _controller.restore(item),
          ),
        ),
      );
  }

  Future<void> _open(FavoritePatent item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PatentDetailsPage(patentId: item.id, hint: item.toSummary()),
      ),
    );
    // патент могли убрать из избранного на его экране
    if (mounted) _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final c = _controller;
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: CustomAppBar(
            title: "Избранное",
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              color: Colors.blueAccent,
              onPressed: () {},
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                color: Colors.blueAccent,
                onPressed: () {},
              ),
            ],
          ),
          body: c.loading
              ? const Center(child: CircularProgressIndicator())
              : c.error != null && c.items.isEmpty
              ? _buildMessage(Icons.error_outline, c.error!, null)
              : c.items.isEmpty
              ? _buildMessage(
                  Icons.star_border,
                  "У вас пока нет избранных патентов",
                  "Добавляйте патенты в избранное, чтобы быстро находить их позже",
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: c.items.length,
                  itemBuilder: (context, index) {
                    final item = c.items[index];
                    return Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _remove(item),
                      child: _buildCard(item),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildCard(FavoritePatent f) {
    final publication = [
      f.country,
      f.documentNumber?.toString() ?? '',
      f.kind,
    ].where((e) => e.isNotEmpty).join(' ');
    final owner = f.patentees.isNotEmpty ? f.patentees : f.applicant;
    final dates = [
      if (f.filingDate != null) 'подана ${_dateFormat.format(f.filingDate!)}',
      if (f.publicationDate != null)
        'опубликована ${_dateFormat.format(f.publicationDate!)}',
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _open(f),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (f.kind.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        documentKindLabel(f.kind),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Убрать из избранного',
                    icon: const Icon(Icons.star, color: Colors.amber),
                    onPressed: () => _remove(f),
                  ),
                ],
              ),
              Text(
                f.title.isEmpty ? 'Без названия' : f.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              if (f.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  f.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 8),
              _row(Icons.confirmation_number_outlined, 'Заявка №', f.applicationNumber),
              _row(Icons.article_outlined, 'Публикация', publication),
              _row(Icons.category_outlined, 'МПК', f.ipc),
              _row(Icons.person_outline, 'Авторы', f.inventors),
              _row(Icons.business_outlined, 'Правообладатель', owner),
              _row(Icons.event_outlined, 'Даты', dates),
              _row(Icons.fingerprint, 'ID', f.id),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(IconData icon, String title, String? subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
