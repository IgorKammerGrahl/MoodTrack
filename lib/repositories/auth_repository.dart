import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

/// Repository responsible for authentication operations and token storage.
class AuthRepository {
  final ApiService _api = ApiService();

  // Singleton
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;
  AuthRepository._internal();

  /// Login and persist credentials.
  Future<User> login(
    StorageService storage,
    String email,
    String password,
  ) async {
    final response = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });

    final token = response['token'];
    final userData = response['user'];
    final refreshToken = response['refreshToken'];

    await storage.setToken(token);
    await storage.setUser(jsonEncode(userData));
    if (refreshToken != null) {
      await storage.setRefreshToken(refreshToken);
    }

    return User.fromJson(userData);
  }

  /// Register and persist credentials.
  Future<User> register(
    StorageService storage,
    String name,
    String email,
    String password,
  ) async {
    final response = await _api.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });

    final token = response['token'];
    final userData = response['user'];
    final refreshToken = response['refreshToken'];

    await storage.setToken(token);
    await storage.setUser(jsonEncode(userData));
    if (refreshToken != null) {
      await storage.setRefreshToken(refreshToken);
    }

    return User.fromJson(userData);
  }

  /// Clear all auth credentials.
  Future<void> clearCredentials(StorageService storage) async {
    await storage.removeToken();
    await storage.removeUser();
    await storage.removeRefreshToken();
  }

  /// Load user from storage (if previously authenticated).
  User? loadUserFromStorage(StorageService storage) {
    final token = storage.getToken();
    final userStr = storage.getUser();

    if (token != null && userStr != null) {
      try {
        final userMap = jsonDecode(userStr);
        return User.fromJson(userMap);
      } catch (e) {
        debugPrint('Erro ao restaurar usuário: $e');
        return null;
      }
    }
    return null;
  }
}
