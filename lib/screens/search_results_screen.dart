import 'package:flutter/material.dart';
import 'package:rospatent/models/search_page_model.dart';
import 'package:rospatent/data/patent_api.dart';
import 'package:rospatent/screens/patent_screen.dart';

import 'analyze_screen.dart';

import '../widgets/custom_app_bar.dart';
import '../widgets/res/bottom_pagination.dart';
import '../widgets/res/patents_header.dart';
import '../widgets/res/patents_list.dart';

class SearchResPage extends StatefulWidget {
  const SearchResPage({super.key});
  static SearchResPageState? state;

  @override
  State<SearchResPage> createState() => state = SearchResPageState();
}

class SearchResPageState extends State<SearchResPage> {
  List<Patent> patents = [];
  int totalFound = 0;
  int _selectedScreenIndex = 1;
  bool _isLoading = true;
  String? _errorMessage;

  List<BottomNavigationBarItem> pageButtons = [
    const BottomNavigationBarItem(icon: Icon(Icons.arrow_back), label: ''),
    const BottomNavigationBarItem(icon: Icon(Icons.circle), label: ''),
    const BottomNavigationBarItem(icon: Icon(Icons.arrow_forward), label: ''),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (SearchPageModel.patents == null) {
        throw Exception('Нет данных для поиска');
      }

      final result = await api.switchPage(SearchPageModel.patents!, 0);

      if (result == null) {
        throw Exception('Получен пустой результат');
      }

      addItemsToPatents(result);
    } catch (e, stackTrace) {
      print('Ошибка загрузки данных: $e');
      print('StackTrace: $stackTrace');

      if (mounted) {
        setState(() {
          _errorMessage = _getUserFriendlyErrorMessage(e);
          _isLoading = false;
        });
      }
    }
  }

  String _getUserFriendlyErrorMessage(Object error) {
    if (error.toString().contains('Unexpected null value')) {
      return 'Ошибка обработки данных от сервера. Некоторые поля отсутствуют.';
    } else if (error.toString().contains('Нет данных для поиска')) {
      return 'Нет данных для отображения. Попробуйте выполнить поиск заново.';
    } else {
      return 'Ошибка загрузки данных. Проверьте подключение к интернету.';
    }
  }

  void addItemsToPatents(SearchResult res) {
    if (!mounted) return;

    setState(() {
      patents = res.patents;
      totalFound = res.total;

      int currentPage = res.currenPage;
      int totalPages = res.pagesCount;

      pageButtons[0] = BottomNavigationBarItem(
        icon: const Icon(Icons.arrow_back),
        label: (currentPage > 0 ? (currentPage - 1) : (totalPages - 1))
            .toString(),
      );
      pageButtons[1] = BottomNavigationBarItem(
        icon: const Icon(Icons.circle),
        label: currentPage.toString(),
      );
      pageButtons[2] = BottomNavigationBarItem(
        icon: const Icon(Icons.arrow_forward),
        label: (currentPage < totalPages - 1 ? (currentPage + 1) : 0)
            .toString(),
      );

      _isLoading = false;
    });
  }

  void _selectScreen(int index) async {
    if (_isLoading) return;

    int pageIndex = int.parse(pageButtons[index].label ?? '0');

    if (!mounted) return;

    setState(() {
      patents.clear();
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await api.switchPage(SearchPageModel.patents!, pageIndex);

      if (result == null) {
        throw Exception('Получен пустой результат');
      }

      addItemsToPatents(result);
    } catch (e, stackTrace) {
      print('Ошибка при смене страницы: $e');
      print('StackTrace: $stackTrace');

      if (mounted) {
        setState(() {
          _errorMessage = _getUserFriendlyErrorMessage(e);
          _isLoading = false;
        });
      }
    }

    setState(() {
      _selectedScreenIndex = index;
    });
  }

  Map<String, int> getLanguageStats(List<Patent> patents) {
    final Map<String, int> langStats = {};
    for (final patent in patents) {
      final lang = patent.snippet?.lang ?? 'Неизвестно';
      langStats[lang] = (langStats[lang] ?? 0) + 1;
    }
    return langStats;
  }

  String getTopOwner(List<Patent> patents) {
    final Map<String, int> ownerCount = {};
    for (final patent in patents) {
      final owner = patent.snippet?.inventor ?? 'Неизвестно';
      ownerCount[owner] = (ownerCount[owner] ?? 0) + 1;
    }

    if (ownerCount.isEmpty) return 'Неизвестно';

    return ownerCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: patents.isEmpty
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnalyzePage(
                          patentsByLanguage: getLanguageStats(patents),
                          totalPatents: totalFound,
                          topOwner: getTopOwner(patents),
                        ),
                      ),
                    );
                  },
          ),
        ],
      ),
      bottomNavigationBar: patents.isNotEmpty || !_isLoading
          ? BottomNavPagination(
              currentIndex: _selectedScreenIndex,
              items: pageButtons,
              onTap: _selectScreen,
            )
          : null,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: _loadInitialData,
                child: const Text('Повторить'),
              ),
            ),
          ],
        ),
      );
    }

    if (patents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Ничего не найдено',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PatentsHeader(totalFound: totalFound),
        Expanded(
          child: PatentsList(
            patents: patents,
            onPatentTap: (patent) {
              SearchPageModel.onPatentClicked(patent);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PatentScreen()),
              );
            },
          ),
        ),
      ],
    );
  }
}
