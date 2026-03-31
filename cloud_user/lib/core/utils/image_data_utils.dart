import 'dart:convert';
import 'dart:typed_data';

bool isDataImageUrl(String? imageUrl) {
  final value = (imageUrl ?? '').trim();
  return value.startsWith('data:image');
}

Uint8List? decodeDataImage(String? imageUrl) {
  final value = (imageUrl ?? '').trim();
  if (!value.startsWith('data:image')) return null;
  final commaIndex = value.indexOf(',');
  if (commaIndex == -1 || commaIndex >= value.length - 1) return null;
  try {
    return base64Decode(value.substring(commaIndex + 1));
  } catch (_) {
    return null;
  }
}
