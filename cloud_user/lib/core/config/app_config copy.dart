// class AppConfig {
//   static const String _prodBaseUrl = 'https://cloudwash.in/api/';
//   static const String _dartDefineApiUrl = String.fromEnvironment('API_URL');

//   // static bool _isLocalHost() {
//   //   final host = Uri.base.host.toLowerCase();
//   //   return host == 'localhost' || host == '127.0.0.1' || host == '0.0.0.0';
//   // }

//   static String get baseUrl {
//     // if (_isLocalHost()) {
//       // Local web builds should work without a separate localhost backend.
//       return _prodBaseUrl;
//     // }

//     final override = _normalizeApiUrl(_dartDefineApiUrl);
//     if (override != null) {
//       return override;
//     }

//     return _prodBaseUrl;
//   }

//   static String? _normalizeApiUrl(String rawUrl) {
//     final url = rawUrl.trim();
//     if (url.isEmpty || url.startsWith('/')) return null;

//     final uri = Uri.tryParse(url);
//     if (uri == null) return null;

//     if (uri.hasScheme) {
//       return uri.toString().endsWith('/') ? uri.toString() : '${uri.toString()}/';
//     }

//     return url.endsWith('/') ? url : '$url/';
//   }
// }
