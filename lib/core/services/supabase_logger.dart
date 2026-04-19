import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class SupabaseLoggingClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final String requestId = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(10);

    // Log Request
    _logRequest(request, requestId);

    try {
      final response = await _inner.send(request);

      // To log the body, we need to read the stream and then return a new one
      final bytes = await response.stream.toBytes();
      final bodyString = utf8.decode(bytes);

      _logResponse(response, requestId, bodyString);

      return http.StreamedResponse(
        Stream.value(bytes),
        response.statusCode,
        contentLength: response.contentLength,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (e) {
      debugPrint('❌ --- [Supabase Request Error] ID: $requestId ---');
      debugPrint('   Error: $e');
      rethrow;
    }
  }

  void _logRequest(http.BaseRequest request, String id) {
    debugPrint('🚀 [Supabase Request] ID: $id');
    debugPrint('   Method: ${request.method}');
    debugPrint('   URL: ${request.url}');
    debugPrint('   Headers: ${_formatHeaders(request.headers)}');

    if (request is http.Request && request.body.isNotEmpty) {
      try {
        final dynamic json = jsonDecode(request.body);
        debugPrint(
          '   Body: ${const JsonEncoder.withIndent('  ').convert(json)}',
        );
      } catch (_) {
        debugPrint('   Body: ${request.body}');
      }
    }
    debugPrint('-------------------------------------------');
  }

  void _logResponse(http.StreamedResponse response, String id, String body) {
    debugPrint('📥 [Supabase Response] ID: $id');
    debugPrint('   Status Code: ${response.statusCode}');
    debugPrint('   Headers: ${_formatHeaders(response.headers)}');

    if (body.isNotEmpty) {
      try {
        final dynamic json = jsonDecode(body);
        debugPrint(
          '   Body: ${const JsonEncoder.withIndent('  ').convert(json)}',
        );
      } catch (_) {
        // Truncate very long non-json responses
        final displayBody = body.length > 500
            ? '${body.substring(0, 500)}...'
            : body;
        debugPrint('   Body: $displayBody');
      }
    }
    debugPrint('✅ --------------------------------------------');
  }

  String _formatHeaders(Map<String, String> headers) {
    final Map<String, String> filteredHeaders = Map.from(headers);
    // Hide sensitive keys if needed
    if (filteredHeaders.containsKey('apikey')) {
      filteredHeaders['apikey'] = '***HIDDEN***';
    }
    if (filteredHeaders.containsKey('Authorization')) {
      filteredHeaders['Authorization'] = 'Bearer ***HIDDEN***';
    }
    return filteredHeaders.toString();
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
