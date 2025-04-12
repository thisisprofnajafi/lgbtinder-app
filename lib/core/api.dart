import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:dating/core/config.dart'; // Ensure this is correctly imported

class Api {
  final Dio _dio = Dio();

  Api() {
    _dio.options.baseUrl = Config.baseUrl;
    _dio.options.receiveTimeout = const Duration(seconds: 15);  // Increased from 10s to 20s
    _dio.options.connectTimeout = const Duration(seconds: 15);

    _dio.options.headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      ...Config.header, // Ensure Config.header is a valid map
    };

    // Add logging interceptor
    _dio.interceptors.add(PrettyDioLogger(
      requestBody: true,
      responseBody: true,
      error: true,
    ));

    // Add error-handling interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint("Request: ${options.method} ${options.path}");
        debugPrint("Headers: ${options.headers}");
        debugPrint("Body: ${options.data}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint("Response: ${response.statusCode}");
        debugPrint("Response Data: ${response.data}");
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        debugPrint("Dio Error: ${error.response?.statusCode}");
        debugPrint("Error Message: ${error.message}");
        return handler.next(error);
      },
    ));
  }

  Dio get sendRequest => _dio;
}
