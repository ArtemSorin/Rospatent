import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rospatent/core/utils/text_utils.dart';
import 'package:rospatent/app/app_scope.dart';
import 'package:rospatent/core/theme/app_colors.dart';
import 'package:rospatent/core/theme/app_text.dart';
import 'package:rospatent/core/widgets/hero_header.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';

import '../widgets/home/date_picker_row.dart';
import '../widgets/home/search_button.dart';
import '../widgets/home/search_input.dart';
import '../widgets/home/sort_section.dart';
import '../widgets/home/text_fields_section.dart';
import 'search_results_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  final _patenteeController = TextEditingController();
  final _authorsController = TextEditingController();

  SortOrder _sort = SortOrder.relevance;
  DateTime? _from;
  DateTime? _to;

  @override
  void dispose() {
    _searchController.dispose();
    _patenteeController.dispose();
    _authorsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final current = isFrom ? _from : _to;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null || !mounted) return;
    setState(() => isFrom ? _from = picked : _to = picked);
  }

  void _search() {
    final from = _from;
    final to = _to;
    if (from != null && to != null && from.isAfter(to)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Дата «от» не может быть позже даты «до»'),
          ),
        );
      return;
    }

    final query = SearchQuery(
      text: _searchController.text.trim(),
      patentees: splitNames(_patenteeController.text),
      authors: splitNames(_authorsController.text),
      sort: _sort,
      publishedFrom: from,
      publishedTo: to,
    );
    // запоминаем запрос для раздела «История»; ошибки хранилища поиску не мешают
    unawaited(
      AppScope.of(context).addSearchHistory(query).catchError((_) {}),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchResultsPage(query: query)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            HeroHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_outlined,
                          size: 22,
                          color: AppColors.brand,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Роспатент',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      HeroIconButton(
                        icon: Icons.notifications_none_rounded,
                        tooltip: 'Уведомления',
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text('Поиск патентов', style: AppText.onDarkTitle),
                  const SizedBox(height: 6),
                  const Text(
                    'Изобретения, полезные модели и промышленные образцы',
                    style: AppText.onDarkBody,
                  ),
                  const SizedBox(height: 20),
                  SearchInput(controller: _searchController, onSubmitted: _search),
                ],
              ),
            ),
            SortSection(
              value: _sort,
              onChanged: (value) => setState(() => _sort = value),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                children: [
                  DatePickerRow(
                    from: _from,
                    to: _to,
                    onPickFrom: () => _pickDate(isFrom: true),
                    onPickTo: () => _pickDate(isFrom: false),
                    onClearFrom: () => setState(() => _from = null),
                    onClearTo: () => setState(() => _to = null),
                  ),
                  const SizedBox(height: 12),
                  TextFieldsSection(
                    patenteeController: _patenteeController,
                    authorsController: _authorsController,
                  ),
                  const SizedBox(height: 20),
                  SearchButton(onPressed: _search),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
