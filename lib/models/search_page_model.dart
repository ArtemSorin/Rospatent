import '../data/patent_api.dart' as api;

import '../screens/patent_screen.dart';
import '../screens/search_results_screen.dart';

class SearchPageModel {
  static api.SearchResult? patents;
  static api.Patent? selectedPatent;

  static void onPatentClicked(api.Patent patent) async {
    selectedPatent = await api.api.getPatent(patent);
    PatentScreen.state!.update();
  }

  static void onSearchClicked(
    String text, {
    String? patentee,
    String? authors,
    int? sortingTypes,
    DateTime? dateLess,
    DateTime? dateGreater,
  }) async {
    api.FindParams params = api.FindParams();
    params.informal = text;
    params.includeFacets = true;

    params.sort = api.SortingTypes.values[sortingTypes ?? 0];

    api.Filter filter = api.Filter();
    bool isFilterNeeded = false;
    if ((patentee ?? "").isNotEmpty) {
      List<String> patentees = patentee!.split(',');
      for (var val in patentees) {
        filter.patentHolders == null
            ? filter.patentHolders = [val]
            : filter.patentHolders!.add(val);
      }
      isFilterNeeded = true;
    }
    if ((authors ?? "").isNotEmpty) {
      List<String> authorsL = authors!.split(',');
      for (var val in authorsL) {
        filter.authors == null
            ? filter.authors = [val]
            : filter.authors!.add(val);
      }
      isFilterNeeded = true;
    }
    if ((dateLess ?? DateTime(0)).year != 0) {
      filter.datePublished.add(api.DateBounce(dateLess!, "<="));
      isFilterNeeded = true;
    }
    if ((dateGreater ?? DateTime(0)).year != 0) {
      filter.datePublished.add(api.DateBounce(dateGreater!, ">="));
      isFilterNeeded = true;
    }

    if (isFilterNeeded) {
      params.filter = filter;
    }

    patents = await api.api.find(params);
    SearchResPage.state!.addItemsToPatents(patents ?? api.SearchResult());
  }
}
