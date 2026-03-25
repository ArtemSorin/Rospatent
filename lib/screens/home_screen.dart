import 'package:flutter/material.dart';

import '../models/search_page_model.dart' as model;

import '../widgets/custom_app_bar.dart';
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
  int sortValue = 1;
  TextEditingController searchTextController = TextEditingController();
  TextEditingController patenteeTextController = TextEditingController();
  TextEditingController authorsTextController = TextEditingController();

  DateTime selectedDateLess = DateTime.now();
  DateTime selectedDateGreater = DateTime.now();

  Future<void> _selectDate(BuildContext context, bool isLess) async {
    final DateTime fallbackDate = DateTime.now();
    final DateTime initialDate = isLess
        ? (selectedDateLess.isBefore(DateTime(1900))
              ? fallbackDate
              : selectedDateLess)
        : (selectedDateGreater.isBefore(DateTime(1900))
              ? fallbackDate
              : selectedDateGreater);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isLess) {
          selectedDateLess = picked;
        } else {
          selectedDateGreater = picked;
        }
      });
    }
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
          SearchInput(controller: searchTextController),
          const SizedBox(height: 16),
          SortSection(
            sortValue: sortValue,
            onChanged: (val) => setState(() => sortValue = val),
          ),
          const SizedBox(height: 16),
          DatePickerRow(
            selectedDateLess: selectedDateLess,
            selectedDateGreater: selectedDateGreater,
            onSelectDate: _selectDate,
          ),
          const SizedBox(height: 16),
          TextFieldsSection(
            patenteeController: patenteeTextController,
            authorsController: authorsTextController,
          ),
          const SizedBox(height: 24),
          SearchButton(
            onPressed: () {
              var today = DateTime.now();
              if (selectedDateGreater.difference(today).inDays == 0) {
                selectedDateGreater = DateTime(0);
              }
              if (selectedDateLess.difference(today).inDays == 0) {
                selectedDateLess = DateTime(0);
              }

              model.SearchPageModel.onSearchClicked(
                searchTextController.text,
                sortingTypes: sortValue - 1,
                patentee: patenteeTextController.text,
                authors: authorsTextController.text,
                dateLess: selectedDateLess,
                dateGreater: selectedDateGreater,
              );

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchResPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
