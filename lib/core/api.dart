import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:dating/core/config.dart'; // Ensure this is correctly imported
import 'package:dating/data/localdatabase.dart';

class Api {
  final Dio _dio = Dio();

  Api() {
    _init();
  }

  Future<void> _init() async {
    _dio.options.baseUrl = Config.baseUrl;
    _dio.options.receiveTimeout = const Duration(seconds: 15);  // Increased from 10s to 20s
    _dio.options.connectTimeout = const Duration(seconds: 15);

    // Get auth token if available
    String token = await Preferences.getToken();

    _dio.options.headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      ...Config.header, // Ensure Config.header is a valid map
    };

    // Add auth token if available
    if (token.isNotEmpty) {
      _dio.options.headers["Authorization"] = "Bearer $token";
    }

    // Add logging interceptor
    _dio.interceptors.add(PrettyDioLogger(
      requestBody: true,
      responseBody: true,
      error: true,
    ));

    // Add error-handling and token refresh interceptor
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
        
        // Check if the response contains a new token
        if (response.data != null && 
            response.data is Map && 
            response.data.containsKey("token") &&
            response.data["token"] != null) {
          updateAuthToken(response.data["token"]);
        }
        
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        debugPrint("Dio Error: ${error.response?.statusCode}");
        debugPrint("Error Message: ${error.message}");
        
        // Handle authentication errors (401)
        if (error.response?.statusCode == 401) {
          // Token expired or invalid
          // Redirect to login or handle as needed
          debugPrint("Authentication error: Token expired or invalid");
        }
        
        return handler.next(error);
      },
    ));
  }

  // Method to update auth token after login/registration
  Future<void> updateAuthToken(String token) async {
    _dio.options.headers["Authorization"] = "Bearer $token";
    await Preferences.saveToken(token);
  }

  Dio get sendRequest => _dio;
}
