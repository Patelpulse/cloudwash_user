final String _logoCacheSeed = DateTime.now().millisecondsSinceEpoch.toString();

String withLogoCacheBust(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty || trimmed.startsWith('data:image')) {
    return trimmed;
  }

  final separator = trimmed.contains('?') ? '&' : '?';
  return '${trimmed}${separator}v=$_logoCacheSeed';
}
