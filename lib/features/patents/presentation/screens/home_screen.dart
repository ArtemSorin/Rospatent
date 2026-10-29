import 'package:flutter/material.dart';
import 'package:rospatent/core/utils/text_utils.dart';
import 'package:rospatent/core/widgets/custom_app_bar.dart';
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchResultsPage(query: query)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Роспатент",
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SearchInput(controller: _searchController, onSubmitted: _search),
          const SizedBox(height: 16),
          SortSection(
            value: _sort,
            onChanged: (value) => setState(() => _sort = value),
          ),
          const SizedBox(height: 16),
          DatePickerRow(
            from: _from,
            to: _to,
            onPickFrom: () => _pickDate(isFrom: true),
            onPickTo: () => _pickDate(isFrom: false),
            onClearFrom: () => setState(() => _from = null),
            onClearTo: () => setState(() => _to = null),
          ),
          const SizedBox(height: 16),
          TextFieldsSection(
            patenteeController: _patenteeController,
            authorsController: _authorsController,
          ),
          const SizedBox(height: 24),
          SearchButton(onPressed: _search),
        ],
      ),
    );
  }
}
