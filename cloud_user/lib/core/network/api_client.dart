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
          print('\n🚀 [API REQUEST] ${options.method} ${options.uri}');
          if (options.headers.isNotEmpty) {
            print('📁 Headers: ${options.headers}');
          }
          if (options.queryParameters.isNotEmpty) {
            print('🔍 Query Params: ${options.queryParameters}');
          }
          if (options.data != null) {
            print('📦 Body: ${options.data}');
          }
          print('--------------------------------------------------');
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('\n✅ [API RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
          print('📄 Data: ${response.data}');
          print('--------------------------------------------------');
        }
        return handler.next(response);
      },
      onError: (DioException error, handler) async {
        if (kDebugMode) {
          print('\n❌ [API ERROR] ${error.response?.statusCode} ${error.requestOptions.uri}');
          print('💬 Message: ${error.message}');
          if (error.response?.data != null) {
            print('📄 Error Data: ${error.response?.data}');
          }
          print('--------------------------------------------------');
        }

        if (error.response?.statusCode == 401) {
          print('🔒 UNAUTHORIZED: Token might be invalid or expired.');
        }

        return handler.next(error);
      },
    ),
  );

  return dio;
}
