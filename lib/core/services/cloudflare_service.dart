import 'dart:convert';
import 'dart:typed_data';


import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Exceptions
// ─────────────────────────────────────────────────────────────────────────────

class CloudflareException implements Exception {
  final String message;
  final int? statusCode;
  const CloudflareException(this.message, {this.statusCode});

  @override
  String toString() => 'CloudflareException($statusCode): $message';
}

// ─────────────────────────────────────────────────────────────────────────────
// Upload progress callback
// ─────────────────────────────────────────────────────────────────────────────

typedef UploadProgressCallback = void Function(int sent, int total);

// ─────────────────────────────────────────────────────────────────────────────
// PresignResult
// ─────────────────────────────────────────────────────────────────────────────

class PresignResult {
  final String uploadUrl;
  final String objectKey;
  const PresignResult({required this.uploadUrl, required this.objectKey});
}

// ─────────────────────────────────────────────────────────────────────────────
// CloudflareService — singleton
// ─────────────────────────────────────────────────────────────────────────────

class CloudflareService {
  CloudflareService._internal();
  static final CloudflareService _instance = CloudflareService._internal();
  factory CloudflareService() => _instance;

  static const String _base = AppConfig.cloudflareWorkerUrl;

  // ── Auth helper ──────────────────────────────────────────────────────────

  String get _jwt {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) throw const CloudflareException('No active session');
    return session.accessToken;
  }

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_jwt',
        'Content-Type': 'application/json',
      };

  // ── Error handling ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _parseResponse(http.Response res) async {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return {};
      return json.decode(res.body) as Map<String, dynamic>;
    }
    String message = 'Request failed (${res.statusCode})';
    try {
      final body = json.decode(res.body) as Map<String, dynamic>;
      message = body['error'] as String? ?? message;
    } catch (_) {}
    throw CloudflareException(message, statusCode: res.statusCode);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 1. Request a presigned PUT URL
  // ─────────────────────────────────────────────────────────────────────────

  Future<PresignResult> requestPresignedUploadUrl({
    required String scope,        // 'course' | 'lecture'
    required String courseId,
    String? lectureId,
    required String fileName,
    required String contentType,
    required int fileSize,        // bytes
  }) async {
    final body = {
      'scope': scope,
      'course_id': courseId,
      if (lectureId != null) 'lecture_id': lectureId,
      'file_name': fileName,
      'content_type': contentType,
      'size': fileSize,
    };

    final res = await http.post(
      Uri.parse('$_base/presign-upload'),
      headers: _headers,
      body: json.encode(body),
    );

    final data = await _parseResponse(res);
    return PresignResult(
      uploadUrl: data['upload_url'] as String,
      objectKey: data['object_key'] as String,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2. Upload file bytes directly to R2 (no proxy)
  //    Streams the file in chunks; calls [onProgress] for large files.
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> uploadFileToR2({
    required String presignedUrl,
    required Uint8List fileBytes,
    required String contentType,
    UploadProgressCallback? onProgress,
  }) async {
    // For large files (video) we use a streaming PUT to track progress.
    // http.StreamedRequest lets us intercept byte chunks.
    final request = http.StreamedRequest('PUT', Uri.parse(presignedUrl));
    request.headers['Content-Type'] = contentType;
    request.headers['Content-Length'] = fileBytes.length.toString();

    // Stream the bytes in 256 KB chunks
    const chunkSize = 256 * 1024;
    int sent = 0;
    final total = fileBytes.length;

    Future<void> stream() async {
      for (int offset = 0; offset < total; offset += chunkSize) {
        final end = (offset + chunkSize).clamp(0, total);
        final chunk = fileBytes.sublist(offset, end);
        request.sink.add(chunk);
        sent += chunk.length;
        onProgress?.call(sent, total);
        // Yield to event loop so UI can repaint
        await Future<void>.delayed(Duration.zero);
      }
      await request.sink.close();
    }

    // Start streaming and sending concurrently
    final client = http.Client();
    try {
      final futureResponse = client.send(request);
      await stream();
      final response = await futureResponse;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final body = await response.stream.bytesToString();
        throw CloudflareException(
          'R2 upload failed (${response.statusCode}): $body',
          statusCode: response.statusCode,
        );
      }
    } finally {
      client.close();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3. Get a signed download URL (10-min TTL)
  // ─────────────────────────────────────────────────────────────────────────

  Future<String> getSignedDownloadUrl(String objectKey) async {
    final uri = Uri.parse('$_base/file-url')
        .replace(queryParameters: {'key': objectKey});

    final res = await http.get(uri, headers: _headers);
    final data = await _parseResponse(res);
    return data['url'] as String;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4. Delete a file from R2
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> deleteFile(String objectKey) async {
    final res = await http.delete(
      Uri.parse('$_base/delete-file'),
      headers: _headers,
      body: json.encode({'object_key': objectKey}),
    );

    if (res.statusCode != 204 && res.statusCode != 200) {
      await _parseResponse(res); // throws CloudflareException
    }
  }
}
