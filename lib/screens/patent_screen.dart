import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:rospatent/data/patent_api.dart';

import '../models/prefs.dart';
import '../models/search_page_model.dart' as model;

import '../widgets/custom_app_bar.dart';

class PatentScreen extends StatefulWidget {
  const PatentScreen({super.key});
  static PatentScreenState? state;

  @override
  State<PatentScreen> createState() => state = PatentScreenState();
}

class PatentScreenState extends State<PatentScreen> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  void update() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _checkFavorite() async {
    final id = model.SearchPageModel.selectedPatent?.id;
    if (id != null) {
      final fav = await Preferences.prefs.isFavorites(id);
      setState(() {
        isFavorite = fav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final id = model.SearchPageModel.selectedPatent?.id;
    if (id != null) {
      if (isFavorite) {
        Preferences.prefs.removeFavorite(id);
      } else {
        Preferences.prefs.addFavorite(id);
      }
      setState(() {
        isFavorite = !isFavorite;
      });
    }
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _infoCard(String text) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: const EdgeInsets.all(12), child: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patent = model.SearchPageModel.selectedPatent ?? Patent.empty();
    final snippet = patent.snippet ?? PatentSnippet.empty();

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
            tooltip: isFavorite
                ? "Убрать из избранного"
                : "Добавить в избранное",
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? Colors.amber : Colors.grey,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Center(
              child: Text(
                patent.title["ru"] ?? "",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          _sectionTitle("Авторы"),
          ...List.generate((patent.inventor["ru"] ?? []).length, (i) {
            return _infoCard(patent.inventor["ru"]![i]);
          }),

          _sectionTitle("Патентообладатели"),
          ...List.generate((patent.patentee["ru"] ?? []).length, (i) {
            return _infoCard(patent.patentee["ru"]![i]);
          }),

          _sectionTitle("Заявитель"),
          _infoCard(snippet.applicant),

          _sectionTitle("Дата публикации"),
          _infoCard(
            DateFormat(
              'yyyy.MM.dd',
            ).format(patent.publicationDate ?? DateTime(0)),
          ),

          _sectionTitle("Дата подачи заявки"),
          _infoCard(
            DateFormat('yyyy.MM.dd').format(patent.filingDate ?? DateTime(0)),
          ),

          _sectionTitle("МПК и CPC"),
          _infoCard("${snippet.ipc}\n${snippet.cpc}"),

          _sectionTitle("Номер патента"),
          _infoCard(patent.number),

          _sectionTitle("Реферат"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: HtmlWidget(patent.abstract["ru"] ?? "-"),
          ),

          _sectionTitle("Формула"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: HtmlWidget(patent.claims["ru"] ?? "-"),
          ),

          _sectionTitle("Описание"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: HtmlWidget(patent.desc["ru"] ?? "-"),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
