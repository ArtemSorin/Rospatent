import '../entities/search_page.dart';
import '../entities/search_query.dart';
import '../repositories/patent_repository.dart';

class SearchPatents {
  final PatentRepository _repository;
  const SearchPatents(this._repository);

  Future<SearchPage> call(
    SearchQuery query, {
    int page = 0,
    int pageSize = 10,
  }) => _repository.search(query, page: page, pageSize: pageSize);
}
