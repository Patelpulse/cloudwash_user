class AppConfig {
  static const String devBaseUrl = 'http://192.168.1.33:5001/api/';
  static const String prodBaseUrl = 'https://cloudwashapi.onrender.com/api/';

  // Toggle this to switch environments
  static const bool isProduction = false;

  static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrl;
}
