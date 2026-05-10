import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FileCacheService
//
// Handles local caching of R2 files on the device.
//  • getCachedPath  → returns the local path if file already downloaded
//  • downloadToCache → streams a signed URL into the app-cache directory,
//                      reports progress via onProgress(0.0–1.0)
//  • openLocal      → opens a locally cached file with the native app
// ─────────────────────────────────────────────────────────────────────────────

class FileCacheService {
  FileCacheService._();
  static final FileCacheService instance = FileCacheService._();

  // Build a stable local filename from the object key
  // e.g. "courses/xxx/files/uuid.pdf" → "courses_xxx_files_uuid.pdf"
  String _localFileName(String objectKey) {
    // Keep the extension, replace slashes with underscores
    return objectKey.replaceAll('/', '_');
  }

  Future<Directory> _cacheDir() async {
    final base = await getApplicationCacheDirectory();
    final dir = Directory('${base.path}/file_cache');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Returns the cached file path if it already exists, else null.
  Future<String?> getCachedPath(String objectKey) async {
    try {
      final dir = await _cacheDir();
      final file = File('${dir.path}/${_localFileName(objectKey)}');
      if (await file.exists()) return file.path;
    } catch (e) {
      debugPrint('[FileCacheService] getCachedPath error: $e');
    }
    return null;
  }

  /// Downloads [signedUrl] into the cache directory, streaming progress.
  /// Returns the local file path on success, or null on failure.
  Future<String?> downloadToCache({
    required String signedUrl,
    required String objectKey,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final dir = await _cacheDir();
      final localPath = '${dir.path}/${_localFileName(objectKey)}';
      final file = File(localPath);

      final request = http.Request('GET', Uri.parse(signedUrl));
      final response = await request.send();

      if (response.statusCode != 200) {
        debugPrint('[FileCacheService] Download failed: ${response.statusCode}');
        return null;
      }

      final total = response.contentLength ?? 0;
      int received = 0;

      final sink = file.openWrite();
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0 && onProgress != null) {
          onProgress((received / total).clamp(0.0, 1.0));
        }
      }
      await sink.flush();
      await sink.close();

      return localPath;
    } catch (e) {
      debugPrint('[FileCacheService] downloadToCache error: $e');
      return null;
    }
  }

  /// Opens [localPath] using the device's native app (PDF viewer, gallery, etc.)
  Future<void> openLocal(String localPath) async {
    try {
      final result = await OpenFilex.open(localPath);
      if (result.type != ResultType.done) {
        debugPrint(
            '[FileCacheService] openLocal failed: ${result.type} — ${result.message}');
      }
    } catch (e) {
      // MissingPluginException happens on the very first launch after adding
      // open_filex if the app wasn't fully rebuilt (cold restart required).
      debugPrint('[FileCacheService] openLocal error: $e');
      rethrow; // let FileCubit catch and show a user-friendly message
    }
  }

}
