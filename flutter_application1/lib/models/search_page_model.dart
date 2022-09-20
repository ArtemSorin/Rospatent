import '../patent_api.dart' as api;

class SearchPageModel {
  static void onSearchClicked(String text,
      {String? patentee, String? authors, int? sortingTypes}) async {
    api.FindParams params = api.FindParams();
    params.informal = text;
    //params.includeFacets = true;

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

    if (isFilterNeeded) {
      params.filter = filter;
    }

    List<api.Patent>? patents = await api.api.find(params);
  }
}
