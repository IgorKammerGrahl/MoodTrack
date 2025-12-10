import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import 'storage_service.dart';

class ApiService {
  final String baseUrl = AppConstants.baseUrl;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

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
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erro de conexão: $e');
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
