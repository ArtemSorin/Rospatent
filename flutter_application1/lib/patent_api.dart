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
    String paramsJson = params.getJson();

    http.Response res = await http.post(Uri.parse("${url}search"),
        headers: headers, body: paramsJson);

    if (res.statusCode == 200) {
      Map data = json.decode(utf8.decode(res.bodyBytes));

      List<Patent>? patents = <Patent>[];
      for (var solution in data["hits"]) {
        Map snippet = solution["snippet"] as Map;
        Patent patent = Patent(
            solution["id"] ?? "",
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

  Future<Patent?> getPatent(String id) async {
    http.Response res =
        await http.get(Uri.parse("${url}docs/${id}"), headers: headers);
    if (res.statusCode == 200) {
      return null;
    } else {
      return null;
    }
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

  String title = "";
  String desc = "";
  String lang = "ru";
  String applicant = "";
  String inventor = "";
  String patantee = "";
  String ipc = "";
  String cpc = "";

  Patent(this.id, this.title, this.desc, this.lang, this.applicant,
      this.inventor, this.patantee, this.ipc, this.cpc);
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

  String getJson() {
    Map<String, Object> data = <String, Object>{};
    if (formal != null) data["q"] = formal as String;
    if (informal != null) data["qn"] = informal as String;
    if (limit != null) data["limit"] = limit.toString();
    if (offset != null) data["offset"] = offset.toString();

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

    if (filter != null) data["filter"] = filter!.getJson();

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
          res += "\"val\",";
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
          res += "\"val\",";
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
          res += "\"val\",";
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
          res += "\"val\",";
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
          res += "\"val\",";
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
          res += "\"val\",";
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
          res += "\"val\",";
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
          res += "\"val\",";
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
          res += "\"val\",";
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

enum SortingTypes { relevance, publicationA, publicationZ, filingA, filingZ }

enum GroupingTypes { docdb, dwpi }

enum DateBounceTypes { greater, greatere, less, lesse }
