import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Compresses image bytes to JPEG at the given max dimension and quality.
/// Returns original bytes if compression fails — guaranteed non-blocking.
Uint8List compressImageBytes(
  Uint8List bytes, {
  int maxDimension = 200,
  int quality = 75,
}) {
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;

    // Only resize if larger than maxDimension
    img.Image resized;
    if (decoded.width > maxDimension || decoded.height > maxDimension) {
      resized = img.copyResize(
        decoded,
        width: decoded.width >= decoded.height ? maxDimension : null,
        height: decoded.height > decoded.width ? maxDimension : null,
        interpolation: img.Interpolation.linear,
      );
    } else {
      resized = decoded;
    }

    final compressed = img.encodeJpg(resized, quality: quality);
    return Uint8List.fromList(compressed);
  } catch (_) {
    // Fallback: return original bytes so the upload never fails
    return bytes;
  }
}
