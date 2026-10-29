import '../entities/patent_details.dart';
import '../entities/search_page.dart';
import '../entities/search_query.dart';

/// Контракт доступа к патентам. Реализация живёт в слое data.
/// Ошибки выбрасываются как Failure.
abstract class PatentRepository {
  Future<SearchPage> search(SearchQuery query, {int page = 0, int pageSize = 10});

  Future<PatentDetails> getDetails(String id);
}
