import 'package:rospatent/core/error/failure.dart';
import 'package:rospatent/features/patents/domain/entities/patent_details.dart';
import 'package:rospatent/features/patents/domain/entities/search_page.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';
import 'package:rospatent/features/patents/domain/repositories/patent_repository.dart';

import '../datasources/rospatent_remote_data_source.dart';
import '../models/json_readers.dart';
import '../models/patent_details_model.dart';
import '../models/patent_summary_model.dart';
import '../models/search_request_mapper.dart';

class PatentRepositoryImpl implements PatentRepository {
  final RospatentRemoteDataSource _remote;
  const PatentRepositoryImpl(this._remote);

  @override
  Future<SearchPage> search(
    SearchQuery query, {
    int page = 0,
    int pageSize = 10,
  }) async {
    final data = await _remote.search(
      SearchRequestMapper.toBody(query, page: page, pageSize: pageSize),
    );
    try {
      final hits = data['hits'] is List ? data['hits'] as List : const [];
      return SearchPage(
        items: hits
            .whereType<Map>()
            .map((h) => PatentSummaryModel.fromHit(Map<String, dynamic>.from(h)))
            .toList(),
        total: int.tryParse(asText(data['total'])) ?? 0,
        page: page,
        pageSize: pageSize,
      );
    } catch (_) {
      throw const ParsingFailure();
    }
  }

  @override
  Future<PatentDetails> getDetails(String id) async {
    final data = await _remote.getDocument(id);
    try {
      return PatentDetailsModel.fromJson(data, fallbackId: id);
    } catch (_) {
      throw const ParsingFailure();
    }
  }
}
