import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class ImageCompressor {
  static const int _maxBytes = 4 * 1024 * 1024; // 4MB Claude API limit

  static Future<String> toBase64(File imageFile) async {
    final Uint8List bytes = await imageFile.readAsBytes();
    if (bytes.lengthInBytes > _maxBytes) {
      throw Exception('Image too large. Please use a smaller image.');
    }
    return base64Encode(bytes);
  }

  static String mimeType(File imageFile) {
    final ext = imageFile.path.split('.').last.toLowerCase();
    const map = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
    };
    return map[ext] ?? 'image/jpeg';
  }
}
