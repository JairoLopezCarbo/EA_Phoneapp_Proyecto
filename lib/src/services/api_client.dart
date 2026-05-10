import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_service.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Uri _uri(String path) => Uri.parse('${ApiConfig.apiBaseUrl}$path');

  Future<dynamic> getJson(String path, {String? token}) {
    return _requestJson('GET', path, token: token);
  }

  Future<dynamic> postJson(String path, {String? token, Object? body}) {
    return _requestJson('POST', path, token: token, body: body);
  }

  Future<dynamic> putJson(String path, {String? token, Object? body}) {
    return _requestJson('PUT', path, token: token, body: body);
  }

  Future<dynamic> deleteJson(String path, {String? token, Object? body}) {
    return _requestJson('DELETE', path, token: token, body: body);
  }

  Future<dynamic> _requestJson(
    String method,
    String path, {
    String? token,
    Object? body,
  }) async {
    final authToken = token ?? await getStoredToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (authToken != null && authToken.trim().isNotEmpty)
        'Authorization': 'Bearer $authToken',
    };

    final request = http.Request(method, _uri(path))
      ..headers.addAll(headers)
      ..body = body == null ? '' : jsonEncode(body);

    final streamedResponse = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    dynamic decoded;
    try {
      decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {
      decoded = response.body;
    }

    if (response.statusCode >= 400) {
      throw ApiException(
        _extractMessage(decoded) ?? 'Request failed.',
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }

  String? _extractMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final direct = decoded['message'];
      if (direct is String && direct.trim().isNotEmpty) {
        return direct;
      }

      final error = decoded['error'];
      if (error is Map<String, dynamic>) {
        final message = error['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }

        final details = error['details'];
        if (details is List && details.isNotEmpty) {
          final first = details.first;
          if (first is Map<String, dynamic>) {
            final detailMessage = first['message'];
            if (detailMessage is String && detailMessage.trim().isNotEmpty) {
              return detailMessage;
            }
          }
        }
      }
    }

    if (decoded is String && decoded.trim().isNotEmpty) {
      return decoded;
    }

    return null;
  }
}

final ApiClient apiClient = ApiClient();
