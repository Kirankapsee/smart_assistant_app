import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../models/chat_message_model.dart';
import '../models/suggestion_model.dart';

// Platform-specific imports
import 'dart:io' if (dart.library.html) 'dart:html' as io_or_html;

// ── Custom exceptions ─────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => statusCode != null
      ? 'ApiException($statusCode): $message'
      : 'ApiException: $message';
}

class NetworkException extends ApiException {
  const NetworkException(super.message);
}

class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode});
}

class ParseException extends ApiException {
  const ParseException(super.message);
}

// ── ApiService ────────────────────────────────────────────
/// Concrete HTTP implementation that calls the real backend.
/// Every public method maps 1-to-1 with a documented endpoint.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  // Protected constructor for subclasses
  ApiService.protected();

  final http.Client _client = http.Client();

  // ── Shared headers ────────────────────────────────────────
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ── GET /suggestions?page={page}&limit={limit} ────────────
  Future<SuggestionPage> getSuggestions({
    int page = 1,
    int limit = AppConstants.defaultPageLimit,
  }) async {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.endpointSuggestions}'
      '?page=$page&limit=$limit',
    );

    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(AppConstants.connectTimeout);

      _assertSuccess(response);

      final body = _decodeBody(response);
      return SuggestionPage.fromJson(body);
    } on ApiException {
      rethrow;
    } on FormatException catch (e) {
      throw ParseException('Invalid JSON response: ${e.message}');
    } catch (e) {
      // On native platforms, catch SocketException and HttpException
      if (!kIsWeb) {
        if (e.toString().contains('SocketException')) {
          throw NetworkException('No internet connection. ${e.toString()}');
        } else if (e.toString().contains('HttpException')) {
          throw NetworkException('HTTP error: ${e.toString()}');
        }
      }
      throw ApiException('Unexpected error: $e');
    }
  }

  // ── POST /chat ────────────────────────────────────────────
  Future<String> sendMessage(String message) async {
    final uri = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.endpointChat}');

    try {
      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({'message': message}),
          )
          .timeout(AppConstants.receiveTimeout);

      _assertSuccess(response);

      final body = _decodeBody(response);

      final reply = body['reply'] as String?;
      if (reply == null || reply.isEmpty) {
        throw const ParseException('Missing "reply" field in response');
      }
      return reply;
    } on ApiException {
      rethrow;
    } on FormatException catch (e) {
      throw ParseException('Invalid JSON response: ${e.message}');
    } catch (e) {
      // On native platforms, catch SocketException and HttpException
      if (!kIsWeb) {
        if (e.toString().contains('SocketException')) {
          throw NetworkException('No internet connection. ${e.toString()}');
        } else if (e.toString().contains('HttpException')) {
          throw NetworkException('HTTP error: ${e.toString()}');
        }
      }
      throw ApiException('Unexpected error: $e');
    }
  }

  // ── GET /chat/history ─────────────────────────────────────
  Future<List<ChatMessage>> getChatHistory() async {
    final uri = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.endpointChatHistory}');

    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(AppConstants.connectTimeout);

      _assertSuccess(response);

      final body = _decodeBody(response);
      final data = body['data'] as List<dynamic>?;
      if (data == null) {
        throw const ParseException('Missing "data" field in history response');
      }
      return data
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } on FormatException catch (e) {
      throw ParseException('Invalid JSON response: ${e.message}');
    } catch (e) {
      // On native platforms, catch SocketException and HttpException
      if (!kIsWeb) {
        if (e.toString().contains('SocketException')) {
          throw NetworkException('No internet connection. ${e.toString()}');
        } else if (e.toString().contains('HttpException')) {
          throw NetworkException('HTTP error: ${e.toString()}');
        }
      }
      throw ApiException('Unexpected error: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────

  /// Throws [ServerException] for any non-2xx status code.
  void _assertSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    String message;
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      message = (body['message'] ?? body['error'] ?? 'Server error').toString();
    } catch (_) {
      message = 'Server returned ${response.statusCode}';
    }

    throw ServerException(message, statusCode: response.statusCode);
  }

  /// Safely decodes the response body as a JSON object.
  Map<String, dynamic> _decodeBody(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw ParseException(
          'Response is not valid JSON:\n${response.body.substring(0, 200)}');
    }
  }

  void dispose() => _client.close();
}
