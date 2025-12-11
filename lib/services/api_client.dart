import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rally/services/auth_repository.dart';

/// Exception thrown when an API call fails.
class ApiException implements Exception {
  /// The HTTP status code.
  final int statusCode;

  /// The error message.
  final String message;

  /// Creates a new [ApiException].
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// HTTP client wrapper for communicating with the backend API.
///
/// Handles:
/// - Base URL configuration from environment
/// - Firebase ID token authentication
/// - Common error handling
/// - JSON encoding/decoding
class ApiClient {
  final AuthRepository _authRepository;
  final http.Client _httpClient;

  /// The base URL for API requests.
  String get baseUrl => dotenv.env['API_BACKEND_URL'] ?? 'http://localhost:8080';

  /// Creates a new [ApiClient].
  ApiClient({required AuthRepository authRepository, http.Client? httpClient})
    : _authRepository = authRepository,
      _httpClient = httpClient ?? http.Client();

  /// Gets the authorization headers with Firebase ID token.
  Future<Map<String, String>> _getHeaders() async {
    final String? token = await _authRepository.getIdToken(forceRefresh: true);
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Handles the response and throws [ApiException] on error.
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    String message;
    try {
      final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
      message = body['message'] as String? ?? body['error'] as String? ?? 'Unknown error';
    } catch (_) {
      message = response.body.isNotEmpty ? response.body : 'Request failed';
    }

    throw ApiException(response.statusCode, message);
  }

  /// Performs a GET request.
  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final Uri uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);
    final Map<String, String> headers = await _getHeaders();
    final http.Response response = await _httpClient.get(uri, headers: headers);
    return _handleResponse(response);
  }

  /// Performs a POST request.
  Future<dynamic> post(String path, {Object? body}) async {
    final Uri uri = Uri.parse('$baseUrl$path');
    final Map<String, String> headers = await _getHeaders();
    final http.Response response = await _httpClient.post(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// Performs a PUT request.
  Future<dynamic> put(String path, {Object? body}) async {
    final Uri uri = Uri.parse('$baseUrl$path');
    final Map<String, String> headers = await _getHeaders();
    final http.Response response = await _httpClient.put(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// Performs a DELETE request.
  Future<dynamic> delete(String path) async {
    final Uri uri = Uri.parse('$baseUrl$path');
    final Map<String, String> headers = await _getHeaders();
    final http.Response response = await _httpClient.delete(uri, headers: headers);
    return _handleResponse(response);
  }

  /// Closes the HTTP client.
  void dispose() {
    _httpClient.close();
  }
}
