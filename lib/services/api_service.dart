import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import 'storage_service.dart';
import 'auth_service.dart';

class ApiService {
  final String baseUrl = AppConstants.baseUrl;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  bool _isRefreshing = false;

  // Headers com token
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      if (Get.isRegistered<StorageService>()) {
        final token = Get.find<StorageService>().getToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }
    } catch (_) {
      // Ignora erro se StorageService não estiver pronto
    }

    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );

      if (response.statusCode == 401) {
        return await _handleUnauthorized(() => get(endpoint));
      }

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 401 && !endpoint.startsWith('/auth')) {
        return await _handleUnauthorized(() => post(endpoint, data));
      }

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  /// Attempts silent token refresh, then retries the original request.
  Future<dynamic> _handleUnauthorized(Future<dynamic> Function() retry) async {
    if (_isRefreshing) {
      throw Exception('Erro API: 401 - Session expired');
    }

    _isRefreshing = true;
    try {
      final storage = Get.find<StorageService>();
      final refreshToken = storage.getRefreshToken();

      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        await storage.setToken(data['token']);
        await storage.setRefreshToken(data['refreshToken']);
        debugPrint('Token refreshed silently.');
        _isRefreshing = false;
        return await retry();
      } else {
        throw Exception('Refresh token invalid');
      }
    } catch (e) {
      _isRefreshing = false;
      debugPrint('Token refresh failed: $e');
      // Refresh failed — force logout
      try {
        if (Get.isRegistered<AuthService>()) {
          Get.find<AuthService>().logout();
        }
      } catch (_) {}
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro API: ${response.statusCode} - ${response.body}');
    }
  }
}
