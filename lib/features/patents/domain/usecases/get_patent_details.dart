import '../entities/patent_details.dart';
import '../entities/patent_summary.dart';
import '../repositories/patent_repository.dart';

class GetPatentDetails {
  final PatentRepository _repository;
  const GetPatentDetails(this._repository);

  /// [hint] — данные из списка поиска/избранного: ими добираются поля,
  /// которых нет в полном документе.
  Future<PatentDetails> call(String id, {PatentSummary? hint}) async {
    final details = await _repository.getDetails(id);
    return details.withFallback(hint);
  }
}
