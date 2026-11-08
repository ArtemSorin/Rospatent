import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:http/http.dart' as http;
import 'package:rospatent/core/error/failure.dart';

/// Низкоуровневый клиент API Роспатента: только HTTP и JSON,
/// без знания о доменных сущностях.
class RospatentRemoteDataSource {
  RospatentRemoteDataSource({
    required this._client,
    required String apiKey,
    this._baseUrl = 'https://searchplatform.rospatent.gov.ru/patsearch/v0.2/',
    this._timeout = const Duration(seconds: 30),
  }) : _headers = {
         'Content-Type': 'application/json',
         'Authorization': apiKey,
       };

  final http.Client _client;
  final String _baseUrl;
  final Duration _timeout;
  final Map<String, String> _headers;

  Future<Map<String, dynamic>> search(Map<String, dynamic> body) {
    return _send(
      () => _client.post(
        Uri.parse('${_baseUrl}search'),
        headers: _headers,
        body: jsonEncode(body),
      ),
    );
  }

  Future<Map<String, dynamic>> getDocument(String id) {
    return _send(
      () => _client.get(
        Uri.parse('${_baseUrl}docs/${Uri.encodeComponent(id)}'),
        headers: _headers,
      ),
    );
  }

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request,
  ) async {
    final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on TimeoutException {
      throw const NetworkFailure('Сервер не отвечает, попробуйте позже');
    } on SocketException {
      throw const NetworkFailure();
    } on http.ClientException {
      throw const NetworkFailure();
    }

    if (response.statusCode != 200) {
      throw ServerFailure(
        'Ошибка сервера (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    try {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      // падаем в ParsingFailure ниже
    }
    throw const ParsingFailure();
  }
}
