import 'package:cloud_user/core/config/app_config.dart';
import 'package:cloud_user/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

@Riverpod(keepAlive: true)
Dio apiClient(ApiClientRef ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
      contentType: Headers.jsonContentType,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        if (kDebugMode) {
          print('🌐 [${options.method}] ${options.uri}');
          print(
            '🔑 Token: ${token != null ? "Present (Starts with ${token.substring(0, 10)}...)" : "MISSING"}',
          );
          print('📂 Headers: ${options.headers}');
          if (options.data != null) print('📦 Data: ${options.data}');
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('✅ [${response.statusCode}] ${response.requestOptions.uri}');
        }
        return handler.next(response);
      },
      onError: (DioException error, handler) async {
        if (kDebugMode) {
          print(
            '❌ [${error.response?.statusCode}] ${error.requestOptions.uri}',
          );
          print('❌ Error Message: ${error.message}');
          print('❌ Request Headers: ${error.requestOptions.headers}');
          print('❌ Response Data: ${error.response?.data}');
        }

        // Handle 401 Unauthorized (optional: trigger logout)
        if (error.response?.statusCode == 401) {
          print('🔒 UNAUTHORIZED: Token might be invalid or expired.');
        }

        return handler.next(error);
      },
    ),
  );

  return dio;
}
