class AppConfig {
  static const String _prodBaseUrl = 'https://cloudwash.in/api/';
  static const String _dartDefineApiUrl = String.fromEnvironment('API_URL');

  static String get baseUrl {
    final override = _normalizeApiUrl(_dartDefineApiUrl);
    if (override != null) {
      return override;
    }

    return _prodBaseUrl;
  }

  static String? _normalizeApiUrl(String rawUrl) {
    final url = rawUrl.trim();
    if (url.isEmpty || url.startsWith('/')) return null;

    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.hasScheme) {
      return uri.toString().endsWith('/') ? uri.toString() : '${uri.toString()}/';
    }

    return url.endsWith('/') ? url : '$url/';
  }
}
