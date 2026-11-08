import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rospatent/app/app_scope.dart';
import 'package:rospatent/core/theme/app_colors.dart';
import 'package:rospatent/core/theme/app_text.dart';
import 'package:rospatent/core/widgets/app_ui.dart';
import 'package:rospatent/core/widgets/hero_header.dart';
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
                            const Text('Избранное', style: AppText.onDarkTitle),
                            const SizedBox(height: 6),
                            Text(
                              c.items.isEmpty
                                  ? 'Сохранённые патенты'
                                  : 'Сохранено: ${c.items.length}',
                              style: AppText.onDarkBody,
                            ),
                          ],
                        ),
                      ),
                      HeroIconButton(
                        icon: Icons.notifications_none_rounded,
                        tooltip: 'Уведомления',
                        onPressed: () {},
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

  Widget _buildBody(FavoritesController c) {
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
        icon: Icons.star_outline_rounded,
        title: 'У вас пока нет избранных патентов',
        subtitle:
            'Добавляйте патенты в избранное, чтобы быстро находить их позже',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: c.items.length,
      itemBuilder: (context, index) {
        final item = c.items[index];
        return Dismissible(
          key: ValueKey(item.id),
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
          onDismissed: (_) => _remove(item),
          child: _buildCard(item),
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

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      onTap: () => _open(f),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (f.kind.isNotEmpty) AppTag(documentKindLabel(f.kind)),
                const Spacer(),
                IconButton(
                  tooltip: 'Убрать из избранного',
                  icon: const Icon(Icons.star_rounded, color: AppColors.amber),
                  onPressed: () => _remove(f),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.title.isEmpty ? 'Без названия' : f.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16.5,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (f.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      f.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodySecondary,
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _row(Icons.confirmation_number_outlined, 'Заявка №', f.applicationNumber),
                  _row(Icons.article_outlined, 'Публикация', publication),
                  _row(Icons.category_outlined, 'МПК', f.ipc),
                  _row(Icons.person_outline_rounded, 'Авторы', f.inventors),
                  _row(Icons.business_outlined, 'Правообладатель', owner),
                  _row(Icons.event_outlined, 'Даты', dates),
                  _row(Icons.fingerprint_rounded, 'ID', f.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.inkTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(color: AppColors.inkSecondary),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
