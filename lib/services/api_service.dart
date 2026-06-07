import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.watch(dioProvider));
});

final class ApiService {
  const ApiService(this._dio);

  final Dio _dio;

  Future<Response<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<Map<String, dynamic>>> post(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.post<Map<String, dynamic>>(
      path,
      data: data,
      options: options,
    );
  }

  Future<Response<Map<String, dynamic>>> patch(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.patch<Map<String, dynamic>>(
      path,
      data: data,
      options: options,
    );
  }

  Future<Response<Map<String, dynamic>>> delete(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.delete<Map<String, dynamic>>(
      path,
      data: data,
      options: options,
    );
  }
}
