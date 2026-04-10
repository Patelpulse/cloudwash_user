import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String _defaultProdApiUrl =
      'https://cloudwash.in/api/';

  static bool _isLocalHost() {
    final host = Uri.base.host.toLowerCase();
    return host == 'localhost' || host == '127.0.0.1' || host == '0.0.0.0';
  }

  static bool _isProductionHost() {
    final host = Uri.base.host.toLowerCase();
    return host == 'admin.cloudwash.in' || host == 'cloudwash.in';
  }

  static bool _isAdminHost() {
    return Uri.base.host.toLowerCase() == 'admin.cloudwash.in';
  }

  static String? _normalizeApiUrl(String? rawUrl) {
    final url = (rawUrl ?? '').trim();
    if (url.isEmpty) return null;

    // Relative URLs like "/api" break when the Flutter web app is served from
    // localhost because they point back at the dev server instead of backend.
    if (url.startsWith('/')) return null;

    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.hasScheme) {
      if (uri.host == 'admin.cloudwash.in') {
        return _ensureTrailingSlash(
          uri.replace(host: 'cloudwash.in').toString(),
        );
      }
      return _ensureTrailingSlash(url);
    }
    if (url.startsWith('localhost:') || url.startsWith('127.0.0.1:')) {
      return _ensureTrailingSlash('http://$url');
    }

    return _ensureTrailingSlash('https://$url');
  }

  static String _ensureTrailingSlash(String url) {
    return url.endsWith('/') ? url : '$url/';
  }

  static Uri apiUri(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    final base = Uri.parse(apiUrl);
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final resolved = base.resolve(normalizedPath);
    if (queryParameters == null || queryParameters.isEmpty) {
      return resolved;
    }

    return resolved.replace(
      queryParameters: queryParameters.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      ),
    );
  }

  static String get apiUrl {
    // Local browser builds should default to production so editors work even
    // when no localhost backend is running. A dart-define can still override
    // this explicitly only on non-local hosts.
    if (_isLocalHost()) {
      return _defaultProdApiUrl;
    }

    // 1. Try dart-define (ideal for Vercel/CI)
    const defineUrl = String.fromEnvironment('API_URL');
    final normalizedDefineUrl = _normalizeApiUrl(defineUrl);
    if (normalizedDefineUrl != null) {
      return normalizedDefineUrl;
    }

    // 2. Try dotenv (for local/existing setup)
    final envUrl = dotenv.env['API_URL'];
    final normalizedEnvUrl = _normalizeApiUrl(envUrl);
    if (normalizedEnvUrl != null) {
      return normalizedEnvUrl;
    }

    if (_isProductionHost()) {
      // The public website can use the same-origin /api proxy, but the admin
      // app is hosted on a separate subdomain and must call the backend origin
      // directly to avoid 404/CORS issues on /api.
      return _isAdminHost() ? _defaultProdApiUrl : '/api/';
    }

    // 3. Fallback
    return _defaultProdApiUrl;
  }
}
