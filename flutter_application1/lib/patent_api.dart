import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth/secrets.dart' as secrets;

class PatentAPI {
  String url = "https://searchplatform.rospatent.gov.ru/patsearch/v0.2/";
  Map<String, String> headers = {
    "Content-Type": "application/json",
    "Authorization": secrets.apiKey
  };

  Future<List<Patent>?> find(FindParams params) async {
    String paramsJson = jsonEncode(params.getJson());

    http.Response res = await http.post(Uri.parse("${url}search"),
        headers: headers, body: paramsJson);

    String responseJson = "";
    if (res.statusCode == 200) {
      Map data = json.decode(utf8.decode(res.bodyBytes));

      List<Patent>? patents = <Patent>[];
      for (var solution in data["hits"]) {
        Map snippet = solution["snippet"] as Map;
        Patent patent = Patent(
            snippet["title"] ?? "",
            snippet["description"] ?? "",
            snippet["lang"] ?? "",
            snippet["applicant"] ?? "",
            snippet["inventor"] ?? "",
            snippet["patantee"] ?? "",
            (snippet["classification"] ?? {})["ipc"] ?? "",
            (snippet["classification"] ?? {})["cpc"] ?? "");
        patents.add(patent);
      }

      return patents;
    } else {
      return null;
    }
  }
}

class Patent {
  String title = "";
  String desc = "";
  String lang = "ru";
  String applicant = "";
  String inventor = "";
  String patantee = "";
  String ipc = "";
  String cpc = "";

  Patent(this.title, this.desc, this.lang, this.applicant, this.inventor,
      this.patantee, this.ipc, this.cpc);
}

class FindParams {
  String? formal;
  String? informal;
  int? limit;
  int? offset;
  SortingTypes? sort = SortingTypes.relevance;
  GroupingTypes? groupBy;
  bool includeFacets = false;
  Filter? filter;

  Map<String, String> getJson() {
    Map<String, String> data = <String, String>{};
    if (formal != null) data["q"] = formal as String;
    if (informal != null) data["qn"] = informal as String;
    if (informal != null) data["limit"] = limit.toString();
    if (informal != null) data["offset"] = offset.toString();

    if (sort != null) {
      String? sortStr;
      switch (sort) {
        case SortingTypes.relevance:
          sortStr = "relevance";
          break;
        case SortingTypes.publicationA:
          sortStr = "publication_date:asc";
          break;
        case SortingTypes.publicationZ:
          sortStr = "publication_date:desc";
          break;
        case SortingTypes.filingA:
          sortStr = "filing_date:asc";
          break;
        case SortingTypes.filingZ:
          sortStr = "filing_date:desc";
          break;
        default:
          sortStr = null;
          break;
      }
      if (sortStr != null) {
        data["sort"] = sortStr;
      }
    }

    if (groupBy != null) data["group_by"] = "family:${groupBy.toString()}";

    if (includeFacets) {
      data["include_facets"] = "1";
    } else {
      data["include_facets"] = "0";
    }

    //if (informal != null) data["filter"] = informal as String;

    return data;
  }
}

class Filter {
  List<String>? authors;
  List<String>? patentHolders;
  List<String>? country;
  List<String>? kind;
  //List<String>? datePublished;
  //List<String>? filingDate;
  List<String>? ipc;
  List<String>? ipcGroup;
  List<String>? ipcSubclass;
  List<String>? cpc;
  List<String>? cpcGroup;
  List<String>? cpcSubclass;
  List<String>? ids;
}

enum SortingTypes { relevance, publicationA, publicationZ, filingA, filingZ }

enum GroupingTypes { docdb, dwpi }
