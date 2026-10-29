import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:rospatent/app/app_scope.dart';
import 'package:rospatent/core/widgets/custom_app_bar.dart';
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
            title: "Выбранный патент",
            centerTitle: true,
            leading: IconButton(
              color: Colors.blueAccent,
              icon: const Icon(Icons.arrow_back_ios),
              tooltip: 'Назад',
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                tooltip: c.favorite
                    ? "Убрать из избранного"
                    : "Добавить в избранное",
                icon: Icon(
                  c.favorite ? Icons.star : Icons.star_border,
                  color: c.favorite ? Colors.amber : Colors.grey,
                ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              c.error ?? 'Не удалось загрузить патент',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: c.load, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(PatentDetails d) {
    final publication = [
      d.country,
      d.documentNumber?.toString() ?? '',
      d.kind,
    ].where((e) => e.isNotEmpty).join(' ');

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            d.title.isEmpty ? 'Без названия' : d.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (d.kind.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              documentKindLabel(d.kind),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.blueAccent),
            ),
          ),

        _section("Авторы"),
        ..._cards(d.inventors),

        _section("Патентообладатели"),
        ..._cards(d.patentees),

        if (d.applicant.isNotEmpty) ...[
          _section("Заявитель"),
          _infoCard(d.applicant),
        ],

        _section("Номер заявки"),
        _infoCard(d.applicationNumber.isEmpty ? '—' : d.applicationNumber),

        _section("Публикация"),
        _infoCard(publication.isEmpty ? '—' : publication),

        _section("Дата подачи заявки"),
        _infoCard(d.filingDate == null ? '—' : _dateFormat.format(d.filingDate!)),

        _section("Дата публикации"),
        _infoCard(
          d.publicationDate == null ? '—' : _dateFormat.format(d.publicationDate!),
        ),

        if (d.ipc.isNotEmpty || d.cpc.isNotEmpty) ...[
          _section("МПК и CPC"),
          _infoCard([d.ipc, d.cpc].where((e) => e.isNotEmpty).join('\n')),
        ],

        _section("Идентификатор"),
        _infoCard(d.id),

        _section("Реферат"),
        _html(d.abstractHtml),

        _section("Формула"),
        _html(d.claimsHtml),

        _section("Описание"),
        _html(d.descriptionHtml),
      ],
    );
  }

  Widget _section(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  List<Widget> _cards(List<String> values) {
    if (values.isEmpty) return [_emptyNote()];
    return values.map(_infoCard).toList();
  }

  Widget _infoCard(String text) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: double.infinity,
        child: Padding(padding: const EdgeInsets.all(12), child: Text(text)),
      ),
    );
  }

  Widget _html(String html) {
    if (html.trim().isEmpty) return _emptyNote();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: HtmlWidget(html),
    );
  }

  Widget _emptyNote() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text('Нет данных', style: TextStyle(color: Colors.black45)),
    );
  }
}
