import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth/secrets.dart' as secrets;

PatentAPI api = PatentAPI();

class PatentAPI {
  String url = "https://searchplatform.rospatent.gov.ru/patsearch/v0.2/";
  Map<String, String> headers = {
    "Content-Type": "application/json",
    "Authorization": secrets.apiKey
  };

  Future<SearchResult?> find(FindParams params) async {
    String paramsJson = params.getJson();

    http.Response res = await http.post(Uri.parse("${url}search"),
        headers: headers, body: paramsJson);

    if (res.statusCode == 200) {
      Map data = json.decode(utf8.decode(res.bodyBytes));

      List<Patent>? patents = <Patent>[];
      SearchResult searchResult = SearchResult();
      searchResult.params = params;

      for (var solution in data["hits"]) {
        Map snippet = solution["snippet"] as Map;
        Patent patent = Patent(
            solution["id"] ?? "",
            snippet["title"] ?? "",
            snippet["description"] ?? "",
            snippet["lang"] ?? "",
            snippet["applicant"] ?? "",
            snippet["inventor"] ?? "",
            snippet["patentee"] ?? "",
            (snippet["classification"] ?? {})["ipc"] ?? "",
            (snippet["classification"] ?? {})["cpc"] ?? "");
        patents.add(patent);
      }

      searchResult.total = data["total"];
      searchResult.count = patents.length;
      searchResult.pagesCount = data["total"] ~/ params.limit;
      searchResult.patents = patents;
      searchResult.currenPage = (params.offset ?? 0) ~/ params.limit;
      return searchResult;
    } else {
      return null;
    }
  }

  Future<SearchResult?> switchPage(SearchResult searched, int page) async {
    int offset = page * (searched.params.limit);
    searched.params.offset = offset;
    return await find(searched.params);
  }

  Future<Patent?> getPatent(Patent p) async {
    String address = "${url}docs/${p.id}";
    http.Response res = await http.get(Uri.parse(address), headers: headers);
    if (res.statusCode == 200) {
      Map data = json.decode(utf8.decode(res.bodyBytes));

      Patent patent = Patent.empty();

      patent.snippet = p.snippet;
      patent.id = data["id"];
      patent.dataset = data["dataset"];
      patent.index = data["index"];
      patent.documentNumber = int.parse(data["common"]["document_number"]);
      patent.number = data["common"]["application"]["number"];
      patent.kind = data["common"]["kind"];
      patent.guid = data["common"]["guid"];
      for (var language in (data["biblio"] as Map).keys) {
        patent.title[language] = data["biblio"][language]["title"] ?? "";
        patent.desc[language] = data["description"][language] ?? "";
        patent.abstract[language] = data["abstract"][language] ?? "";
        patent.claims[language] = data["claims"][language] ?? "";

        for (var inv in (data["biblio"][language]["inventor"] as List)) {
          if (patent.inventor[language] == null) patent.inventor[language] = [];
          patent.inventor[language]!.add(inv["name"]);
        }
        for (var pat in (data["biblio"][language]["patentee"] as List)) {
          if (patent.patentee[language] == null) patent.patentee[language] = [];
          patent.patentee[language]!.add(pat["name"]);
        }
      }

      patent.publicationDate = DateTime.parse(
          (data["common"]["publication_date"] as String).replaceAll('.', '-'));
      patent.filingDate = DateTime.parse(
          (data["common"]["application"]["filing_date"] as String)
              .replaceAll('.', '-'));

      for (var drt in data["drawings"] ?? []) {
        patent.drawings.add(Drawing(
            drt["url"], int.parse(drt["width"]), int.parse(drt["height"])));
      }

      return patent;
    } else {
      return null;
    }
  }

  void fillPatent(Patent patent) async {
    String address = "${url}docs/${patent.id}";
    http.Response res = await http.get(Uri.parse(address), headers: headers);
    if (res.statusCode == 200) {
      Map data = json.decode(utf8.decode(res.bodyBytes));

      patent.id = data["id"];
      patent.dataset = data["dataset"];
      patent.index = data["index"];
      patent.documentNumber = int.parse(data["common"]["document_number"]);
      patent.number = data["common"]["application"]["number"];
      patent.kind = data["common"]["kind"];
      patent.guid = data["common"]["guid"];
      for (var language in (data["biblio"] as Map).keys) {
        patent.title[language] = data["biblio"][language]["title"];
        patent.desc[language] = data["description"][language];
        patent.abstract[language] = data["abstract"][language];
        patent.claims[language] = data["claims"][language];

        for (var inv in (data["biblio"][language]["inventor"] as List)) {
          if (patent.inventor[language] == null) patent.inventor[language] = [];
          patent.inventor[language]!.add(inv["name"]);
        }
        for (var pat in (data["biblio"][language]["patentee"] as List)) {
          if (patent.patentee[language] == null) patent.patentee[language] = [];
          patent.patentee[language]!.add(pat["name"]);
        }
      }

      patent.publicationDate = DateTime.parse(
          (data["common"]["publication_date"] as String).replaceAll('.', '-'));
      patent.filingDate = DateTime.parse(
          (data["common"]["application"]["filing_date"] as String)
              .replaceAll('.', '-'));

      for (var drt in data["drawings"] ?? []) {
        patent.drawings.add(Drawing(
            drt["url"], int.parse(drt["width"]), int.parse(drt["height"])));
      }
    }
  }

  Future<List<Patent>> findSimilarByPatent(Patent example, int count) async {
    List<Patent> results = [];
    String id = example.id;
    String paramsJson =
        '{"type_search": "id_search", "pat_id": "$id", "count": $count}';

    http.Response res = await http.post(Uri.parse("${url}similar_search"),
        headers: headers, body: paramsJson);

    if (res.statusCode == 200) {
      Map data = json.decode(utf8.decode(res.bodyBytes));
      for (var patent in data["data"]) {
        Patent p = Patent.fromJson(patent);
        results.add(p);
      }
    }

    return results;
  }

  Future<List<Patent>> findSimilarById(String id, int count) async {
    List<Patent> results = [];
    String paramsJson =
        '{"type_search": "id_search", "pat_id": "$id", "count": $count}';

    http.Response res = await http.post(Uri.parse("${url}similar_search"),
        headers: headers, body: paramsJson);

    if (res.statusCode == 200) {
      Map data = json.decode(utf8.decode(res.bodyBytes));
      for (var patent in data["data"]) {
        Patent p = Patent.fromJson(patent);
        results.add(p);
      }
    }

    return results;
  }
}

class Patent {
  String id = "";

  int documentNumber = -1;
  String number = "";
  String kind = "";
  String guid = "";
  DateTime? publicationDate;
  DateTime? filingDate;

  String index = "";
  String dataset = "";

  Map<String, List<String>> inventor = {};
  Map<String, List<String>> patentee = {};

  Map<String, String> title = {};
  Map<String, String> desc = {};
  Map<String, String> abstract = {}; //Реферат
  Map<String, String> claims = {}; //Формула

  List<Drawing> drawings = [];

  PatentSnippet? snippet;

  Patent(this.id, title, desc, lang, applicant, inventor, patentee, ipc, cpc) {
    snippet = PatentSnippet(
        title, desc, lang, applicant, inventor, patentee, ipc, cpc);
  }
  Patent.empty();
  Patent.fromJson(Map data) {
    id = data["id"] ?? "";
    dataset = data["dataset"] ?? "";
    index = data["index"] ?? "";
    documentNumber = int.parse(data["common"]["document_number"] ?? "-1");
    number = data["common"]["application"]["number"] ?? "";
    kind = data["common"]["kind"] ?? "";
    guid = data["common"]["guid"] ?? "";
    for (var language in (data["biblio"] as Map).keys) {
      title[language] = data["biblio"][language]["title"] ?? "";
      desc[language] = (data["description"] ?? {})[language] ?? "";
      abstract[language] = (data["abstract"] ?? {})[language] ?? "";
      claims[language] = (data["claims"] ?? {})[language] ?? "";

      for (var inv in (data["biblio"][language]["inventor"] ?? [])) {
        if (inventor[language] == null) inventor[language] = [];
        inventor[language]!.add(inv["name"]);
      }
      for (var pat in (data["biblio"][language]["patentee"] ?? [])) {
        if (patentee[language] == null) patentee[language] = [];
        patentee[language]!.add(pat["name"]);
      }
    }

    snippet = PatentSnippet(
        data["snippet"]["title"] ?? "",
        data["snippet"]["description"] ?? "",
        data["snippet"]["lang"] ?? "",
        data["snippet"]["applicant"] ?? "",
        data["snippet"]["inventor"] ?? "",
        data["snippet"]["patentee"] ?? "",
        (data["snippet"]["classification"] ?? {})["ipc"] ?? "",
        (data["snippet"]["classification"] ?? {})["cpc"] ?? "");

    publicationDate = DateTime.parse(
        (data["common"]["publication_date"] as String).replaceAll('.', '-'));
    filingDate = DateTime.parse(
        (data["common"]["application"]["filing_date"] as String)
            .replaceAll('.', '-'));

    for (var drt in data["drawings"] ?? []) {
      drawings.add(Drawing(
          drt["url"], int.parse(drt["width"]), int.parse(drt["height"])));
    }
  }
}

class PatentSnippet {
  String title = "";
  String desc = "";
  String lang = "ru";
  String applicant = "";
  String inventor = "";
  String patentee = "";
  String ipc = "";
  String cpc = "";

  PatentSnippet(this.title, this.desc, this.lang, this.applicant, this.inventor,
      this.patentee, this.ipc, this.cpc);
  PatentSnippet.empty();
}

class FindParams {
  String? formal;
  String? informal;
  int limit = 10;
  int? offset;
  SortingTypes? sort = SortingTypes.relevance;
  GroupingTypes? groupBy;
  bool includeFacets = false;
  Filter? filter;
  List<Dataset> datasets = [Dataset.available[2]];

  String getJson() {
    Map<String, Object> data = <String, Object>{};
    if (formal != null) data["q"] = formal as String;
    if (informal != null) data["qn"] = informal as String;
    if (limit != null) data["limit"] = limit as Object;
    if (offset != null) data["offset"] = offset as Object;

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
      data["include_facets"] = 1;
    } else {
      data["include_facets"] = 0;
    }

    if (filter != null) data["filter"] = json.decode(filter!.getJson());

    data["datasets"] = <String>[];
    for (var val in datasets) {
      (data["datasets"] as List<String>).add(val.id);
    }

    return jsonEncode(data);
  }
}

class Filter {
  List<String>? authors;
  List<String>? patentHolders;
  List<String>? country;
  List<String>? kind;
  DateBounce? datePublished;
  DateBounce? filingDate;
  List<String>? ipc;
  List<String>? ipcGroup;
  List<String>? ipcSubclass;
  List<String>? cpc;
  List<String>? cpcGroup;
  List<String>? cpcSubclass;
  List<String>? ids;

  String getJson() {
    String res = "{";

    if (authors != null) {
      res += "\"authors\": {\"values\":[";
      if (authors!.length == 1) {
        res += "\"${authors![0]}\"";
      } else {
        for (String author in authors!) {
          res += "\"$author\",";
        }
        res = res.substring(0, res.length - 1);
      }
      res += "]},";
    }
    if (patentHolders != null) {
      res += "\"authors\": {\"values\":[";
      if (patentHolders!.length == 1) {
        res += "\"${patentHolders![0]}\"";
      } else {
        for (String patentHolder in patentHolders!) {
          res += "\"$patentHolder\",";
        }
        res = res.substring(0, res.length - 1);
      }
      res += "]},";
    }
    if (country != null) {
      res += "\"country\": {\"values\":[";
      if (country!.length == 1) {
        res += "\"${country![0]}\"";
      } else {
        for (String val in country!) {
          res += "\"$val\",";
        }
        res = res.substring(0, res.length - 1);
      }
      res += "]},";
    }
    if (kind != null) {
      res += "\"kind\": {\"values\":[";
      if (kind!.length == 1) {
        res += "\"${kind![0]}\"";
      } else {
        for (String val in kind!) {
          res += "\"$val\",";
        }
        res = res.substring(0, res.length - 1);
      }
      res += "]},";
    }
    if (ipc != null) {
      res += "\"ipc\": {\"values\":[";
      if (ipc!.length == 1) {
        res += "\"${ipc![0]}\"";
      } else {
        for (String val in ipc!) {
          res += "\"$val\",";
        }
        res = res.substring(0, res.length - 1);
      }
      res += "]},";
    }
    if (ipcGroup != null) {
      res += "\"ipcGroup\": {\"values\":[";
      if (ipcGroup!.length == 1) {
        res += "\"${ipcGroup![0]}\"";
      } else {
        for (String val in ipcGroup!) {
          res += "\"$val\",";
        }
        res = res.substring(0, res.length - 1);
      }
      res += "]},";
    }
    if (ipcSubclass != null) {
      res += "\"ipcSubclass\": {\"values\":[";
      if (ipcSubclass!.length == 1) {
        res += "\"${ipcSubclass![0]}\"";
      } else {
        for (String val in ipcSubclass!) {
          res += "\"$val\",";
        }
        res = res.substring(0, res.length - 1);
      }
      res += "]},";
    }
    if (cpc != null) {
      res += "\"cpc\": {\"values\":[";
      if (cpc!.length == 1) {
        res += "\"${cpc![0]}\"";
      } else {
        for (String val in cpc!) {
          res += "\"$val\",";
        }
        res = res.substring(0, res.length - 1);
      }
      res += "]},";
    }
    if (cpcGroup != null) {
      res += "\"cpcGroup\": {\"values\":[";
      if (cpcGroup!.length == 1) {
        res += "\"${cpcGroup![0]}\"";
      } else {
        for (String val in cpcGroup!) {
          res += "\"$val\",";
        }
        res = res.substring(0, res.length - 1);
      }
      res += "]},";
    }
    if (cpcSubclass != null) {
      res += "\"cpcSubclass\": {\"values\":[";
      if (cpcSubclass!.length == 1) {
        res += "\"${cpcSubclass![0]}\"";
      } else {
        for (String val in cpcSubclass!) {
          res += "\"$val\",";
        }
        res = res.substring(0, res.length - 1);
      }
      res += "]},";
    }
    if (ids != null) {
      res += "\"ids\": {\"values\":[";
      if (ids!.length == 1) {
        res += "\"${ids![0]}\"";
      } else {
        for (String val in ids!) {
          res += "\"$val\",";
        }
        res = res.substring(0, res.length - 1);
      }
      res += "]},";
    }
    if (datePublished != null) {
      res += "\"date_published\": {\"range\":${datePublished!.getJson()}},";
    }
    if (filingDate != null) {
      res += "\"date_published\": {\"range\":${filingDate!.getJson()}},";
    }

    res = res.substring(0, res.length - 1);
    res += "}";
    return res;
  }
}

class DateBounce {
  DateTime _date = DateTime(1970);
  DateBounceTypes _position = DateBounceTypes.lesse;

  DateBounce.fromString(String dateString, String position) {
    _date = DateTime.parse(dateString);
    switch (position) {
      case ">":
        _position = DateBounceTypes.greater;
        break;
      case "<":
        _position = DateBounceTypes.less;
        break;
      case ">=":
        _position = DateBounceTypes.greatere;
        break;
      case "<=":
        _position = DateBounceTypes.lesse;
        break;
    }
  }
  DateBounce(DateTime date, String position) {
    _date = date;
    switch (position) {
      case ">":
        _position = DateBounceTypes.greater;
        break;
      case "<":
        _position = DateBounceTypes.less;
        break;
      case ">=":
        _position = DateBounceTypes.greatere;
        break;
      case "<=":
        _position = DateBounceTypes.lesse;
        break;
    }
  }

  String getJson() {
    String res = "{";
    switch (_position) {
      case DateBounceTypes.greater:
        res += "\"gt\": \"";
        break;
      case DateBounceTypes.greatere:
        res += "\"gte\": \"";
        break;
      case DateBounceTypes.less:
        res += "\"lt\": \"";
        break;
      case DateBounceTypes.lesse:
        res += "\"lte\": \"";
        break;
    }

    res +=
        "${_date.year}${_date.month < 10 ? "0${_date.month}" : _date.month}${_date.day < 10 ? "0${_date.day}" : _date.day}\"}";
    return res;
  }
}

class Drawing {
  String url = "";
  int width = 0;
  int height = 0;

  Drawing(this.url, this.width, this.height);
}

class Dataset {
  String category = "";
  String id = "";
  String name = "";

  static List<Dataset> available = [
    Dataset("ru_till_1994", "Россия до 1994 года", "Россия и страны СНГ"),
    Dataset("ru_since_1994", "Россия с 1994 года", "Россия и страны СНГ"),
    Dataset("cis", "Патентные документы СНГ", "Россия и страны СНГ"),
  ];

  Dataset(this.id, this.name, this.category);
}

class SearchResult {
  int total = 0;
  int count = 0;
  int pagesCount = 0;
  int currenPage = 0;

  FindParams params = FindParams();

  List<Patent> patents = [];
}

enum SortingTypes { relevance, publicationA, publicationZ, filingA, filingZ }

enum GroupingTypes { docdb, dwpi }

enum DateBounceTypes { greater, greatere, less, lesse }
