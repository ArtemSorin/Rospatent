import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:rospatent/app/app_scope.dart';
import 'package:rospatent/core/theme/app_colors.dart';
import 'package:rospatent/core/theme/app_text.dart';
import 'package:rospatent/core/widgets/app_ui.dart';
import 'package:rospatent/core/widgets/custom_app_bar.dart';
import 'package:rospatent/core/widgets/hero_header.dart';
import 'package:rospatent/features/patents/domain/entities/document_kind.dart';
import 'package:rospatent/features/patents/domain/entities/patent_details.dart';
import 'package:rospatent/features/patents/domain/entities/patent_summary.dart';

import '../controllers/patent_details_controller.dart';

class PatentDetailsPage extends StatefulWidget {
  final String patentId;

  /// Данные из списка поиска/избранного: показываются, пока в документе пусто.
  final PatentSummary? hint;

  const PatentDetailsPage({super.key, required this.patentId, this.hint});

  @override
  State<PatentDetailsPage> createState() => _PatentDetailsPageState();
}

class _PatentDetailsPageState extends State<PatentDetailsPage> {
  late final PatentDetailsController _controller;
  final _dateFormat = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    final deps = AppScope.of(context);
    _controller = PatentDetailsController(
      getPatentDetails: deps.getPatentDetails,
      isFavorite: deps.isFavorite,
      addFavorite: deps.addFavorite,
      removeFavorite: deps.removeFavorite,
      patentId: widget.patentId,
      hint: widget.hint,
    )..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final c = _controller;
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Выбранный патент',
            leading: const AppBackButton(),
            actions: [
              AppBarButton(
                tooltip: c.favorite
                    ? 'Убрать из избранного'
                    : 'Добавить в избранное',
                icon: c.favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                color: c.favorite ? AppColors.amber : AppColors.brand,
                background: c.favorite ? AppColors.amberSoft : AppColors.brandSoft,
                onPressed: c.details == null ? null : c.toggleFavorite,
              ),
            ],
          ),
          body: _buildBody(c),
        );
      },
    );
  }

  Widget _buildBody(PatentDetailsController c) {
    final details = c.details;
    if (details != null) return _buildContent(details);
    if (c.loading) return const Center(child: CircularProgressIndicator());
    return StateView(
      icon: Icons.wifi_off_rounded,
      isError: true,
      title: 'Не удалось загрузить патент',
      subtitle: c.error,
      actionLabel: 'Повторить',
      onAction: c.load,
    );
  }

  Widget _buildContent(PatentDetails d) {
    final publication = [
      d.country,
      d.documentNumber?.toString() ?? '',
      d.kind,
    ].where((e) => e.isNotEmpty).join(' ');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _heroCard(d, publication),
        const SectionTitle('Реквизиты', padding: EdgeInsets.fromLTRB(0, 24, 0, 10)),
        _requisites(d, publication),
        const SectionTitle('Авторы', padding: EdgeInsets.fromLTRB(0, 24, 0, 10)),
        _people(d.inventors, Icons.person_outline_rounded, initials: true),
        const SectionTitle(
          'Патентообладатели',
          padding: EdgeInsets.fromLTRB(0, 24, 0, 10),
        ),
        _people(d.patentees, Icons.business_outlined),
        const SizedBox(height: 24),
        _textSection('Реферат', d.abstractHtml, initiallyExpanded: true),
        _textSection('Формула', d.claimsHtml),
        _textSection('Описание', d.descriptionHtml),
      ],
    );
  }

  Widget _heroCard(PatentDetails d, String publication) {
    return HeroHeader(
      safeTop: false,
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (d.kind.isNotEmpty) ...[
            AppTag.onDark(documentKindLabel(d.kind)),
            const SizedBox(height: 14),
          ],
          Text(
            d.title.isEmpty ? 'Без названия' : d.title,
            style: const TextStyle(
              fontSize: 20,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          if (publication.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.article_outlined, size: 18, color: Color(0xCCFFFFFF)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(publication, style: AppText.onDarkBody),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Реквизиты сгруппированы по смыслу: документ, даты, участники заявки,
  /// классификация, идентификатор. Короткие значения идут парами в две колонки,
  /// длинные — на всю ширину.
  Widget _requisites(PatentDetails d, String publication) {
    String orDash(String v) => v.trim().isEmpty ? '—' : v;
    String date(DateTime? v) => v == null ? '—' : _dateFormat.format(v);

    final ipcCodes = _codes(d.ipc);
    final cpcCodes = _codes(d.cpc);

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _pair(
            _Tile('Номер заявки', orDash(d.applicationNumber), Icons.tag_rounded),
            _Tile('Публикация', orDash(publication), Icons.article_outlined),
          ),
          const SizedBox(height: 8),
          _pair(
            _Tile('Дата подачи', date(d.filingDate), Icons.event_available_outlined),
            _Tile('Дата публикации', date(d.publicationDate), Icons.event_note_outlined),
          ),
          if (d.applicant.isNotEmpty) ...[
            const SizedBox(height: 8),
            _tile(_Tile('Заявитель', d.applicant, Icons.business_outlined)),
          ],
          if (ipcCodes.isNotEmpty || cpcCodes.isNotEmpty) ...[
            const SizedBox(height: 8),
            _classification(ipcCodes, cpcCodes),
          ],
          const SizedBox(height: 8),
          _identifier(d.id),
        ],
      ),
    );
  }

  /// Две плитки одной высоты в ряд.
  Widget _pair(_Tile left, _Tile right) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _tile(left)),
          const SizedBox(width: 8),
          Expanded(child: _tile(right)),
        ],
      ),
    );
  }

  Widget _tile(_Tile t) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(t.icon, size: 16, color: AppColors.brand),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  t.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SelectableText(
            t.value,
            style: const TextStyle(
              fontSize: 15,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  /// МПК и CPC — коды чипами, а не строкой текста.
  Widget _classification(List<String> ipc, List<String> cpc) {
    Widget group(String label, List<String> codes) {
      if (codes.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.caption),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final c in codes) AppTag(c)],
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.category_outlined, size: 16, color: AppColors.brand),
              SizedBox(width: 6),
              Text('Классификация', style: AppText.caption),
            ],
          ),
          const SizedBox(height: 10),
          group('МПК', ipc),
          if (ipc.isNotEmpty && cpc.isNotEmpty) const SizedBox(height: 10),
          group('CPC', cpc),
        ],
      ),
    );
  }

  /// Идентификатор с кнопкой «скопировать».
  Widget _identifier(String id) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.fingerprint_rounded, size: 16, color: AppColors.brand),
          const SizedBox(width: 6),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Идентификатор', style: AppText.caption),
                  const SizedBox(height: 2),
                  Text(
                    id,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Скопировать',
            icon: const Icon(Icons.copy_rounded, size: 20),
            color: AppColors.brand,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: id));
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text('Идентификатор скопирован')));
            },
          ),
        ],
      ),
    );
  }

  List<String> _codes(String raw) => raw
      .split(RegExp(r'[\n;,]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Widget _people(List<String> values, IconData icon, {bool initials = false}) {
    if (values.isEmpty) return _emptyCard();
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < values.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 68),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.brandSoft,
                      shape: BoxShape.circle,
                    ),
                    child: initials && values[i].trim().isNotEmpty
                        ? Text(
                            values[i].trim()[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brand,
                            ),
                          )
                        : Icon(icon, size: 20, color: AppColors.brand),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SelectableText(
                      values[i],
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Длинные тексты (реферат, формула, описание) сворачиваются в карточки-аккордеоны.
  Widget _textSection(String title, String html, {bool initiallyExpanded = false}) {
    if (html.trim().isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AppCard(
          child: Row(
            children: [
              Expanded(child: Text(title, style: AppText.h3)),
              const Text(
                'Нет данных',
                style: TextStyle(fontSize: 14, color: AppColors.inkTertiary),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            shape: const Border(),
            collapsedShape: const Border(),
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            iconColor: AppColors.brand,
            collapsedIconColor: AppColors.brand,
            title: Text(title, style: AppText.h3),
            children: [
              HtmlWidget(
                html,
                textStyle: const TextStyle(
                  fontSize: 14.5,
                  height: 1.5,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyCard() {
    return const AppCard(
      child: Text(
        'Нет данных',
        style: TextStyle(fontSize: 14, color: AppColors.inkTertiary),
      ),
    );
  }
}

class _Tile {
  final String label;
  final String value;
  final IconData icon;

  const _Tile(this.label, this.value, this.icon);
}
