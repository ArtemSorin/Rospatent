import 'package:flutter/foundation.dart';
import 'package:rospatent/core/error/failure.dart';
import 'package:rospatent/features/favorites/domain/usecases/add_favorite.dart';
import 'package:rospatent/features/favorites/domain/usecases/is_favorite.dart';
import 'package:rospatent/features/favorites/domain/usecases/remove_favorite.dart';
import 'package:rospatent/features/patents/domain/entities/patent_details.dart';
import 'package:rospatent/features/patents/domain/entities/patent_summary.dart';
import 'package:rospatent/features/patents/domain/usecases/get_patent_details.dart';

class PatentDetailsController extends ChangeNotifier {
  PatentDetailsController({
    required GetPatentDetails getPatentDetails,
    required IsFavorite isFavorite,
    required AddFavorite addFavorite,
    required RemoveFavorite removeFavorite,
    required this.patentId,
    this.hint,
  }) : _getPatentDetails = getPatentDetails,
       _isFavorite = isFavorite,
       _addFavorite = addFavorite,
       _removeFavorite = removeFavorite;

  final GetPatentDetails _getPatentDetails;
  final IsFavorite _isFavorite;
  final AddFavorite _addFavorite;
  final RemoveFavorite _removeFavorite;

  final String patentId;
  final PatentSummary? hint;

  PatentDetails? details;
  bool loading = true;
  bool favorite = false;
  String? error;

  bool _disposed = false;

  Future<void> load() async {
    loading = true;
    error = null;
    _notify();

    try {
      favorite = await _isFavorite(patentId);
    } catch (_) {
      favorite = false;
    }

    try {
      details = await _getPatentDetails(patentId, hint: hint);
    } on Failure catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Не удалось загрузить патент';
    }
    loading = false;
    _notify();
  }

  Future<void> toggleFavorite() async {
    final current = details;
    if (current == null) return;
    try {
      if (favorite) {
        await _removeFavorite(patentId);
      } else {
        await _addFavorite(current);
      }
      favorite = !favorite;
      _notify();
    } catch (_) {
      // состояние звезды остаётся прежним
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
