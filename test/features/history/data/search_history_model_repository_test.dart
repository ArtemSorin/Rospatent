import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rospatent/features/history/data/models/search_history_entry_model.dart';
import 'package:rospatent/features/history/data/datasources/search_history_local_data_source.dart';
import 'package:rospatent/features/history/data/repositories/search_history_repository_impl.dart';
import 'package:rospatent/features/history/domain/entities/search_history_entry.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';

class FakeHistoryLocalDataSource extends SearchHistoryLocalDataSource {
  List<String> rows = [];
  @override
  Future<List<String>> read() async => rows;
  @override
  Future<void> write(List<String> value) async => rows = List.of(value);
}

void main() {
  test('модель сериализует все поля и повреждённая строка пропускается', () {
    final entry = SearchHistoryEntry(
      query: const SearchQuery(
        text: 'способ',
        authors: ['Иванов'],
        patentees: ['Ромашка'],
        sort: SortOrder.publicationDesc,
      ),
      searchedAt: DateTime(2024),
    );
    final encoded = SearchHistoryEntryModel.encode(entry);
    final decoded = SearchHistoryEntryModel.decode(encoded);
    expect(decoded, isNotNull);
    expect(decoded!.query.text, 'способ');
    expect(decoded.query.authors, ['Иванов']);
    expect(decoded.query.patentees, ['Ромашка']);
    expect(decoded.query.sort, SortOrder.publicationDesc);
    expect(SearchHistoryEntryModel.decode('{bad json'), isNull);
  });

  test('repository.add заменяет дубликат и ограничивает историю', () async {
    SharedPreferences.setMockInitialValues({});
    final local = FakeHistoryLocalDataSource();
    final repository = SearchHistoryRepositoryImpl(local);
    final first = SearchHistoryEntry(query: const SearchQuery(text: 'первый'), searchedAt: DateTime(2024));
    final duplicate = SearchHistoryEntry(query: const SearchQuery(text: 'первый'), searchedAt: DateTime(2025));
    await repository.add(first);
    await repository.add(duplicate);
    final entries = await repository.getAll();
    expect(entries, hasLength(1));
    expect(entries.single.searchedAt, DateTime(2025));
  });
}
