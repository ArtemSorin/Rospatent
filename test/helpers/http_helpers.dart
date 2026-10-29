import 'dart:convert';

import 'package:http/http.dart' as http;

/// JSON-ответ в UTF-8 (кириллица корректно кодируется).
http.Response jsonResponse(Object body, [int status = 200]) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
