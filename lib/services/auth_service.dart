import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/user.dart';
import '../controllers/mood_controller.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'database_service.dart';

class AuthService extends GetxService {
  final ApiService _api = ApiService();
  final StorageService _storage = Get.find<StorageService>();

  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  void _loadUserFromStorage() {
    final token = _storage.getToken();
    final userStr = _storage.getUser();

    if (token != null && userStr != null) {
      try {
        final userMap = jsonDecode(userStr);
        currentUser.value = User.fromJson(userMap);
        isLoggedIn.value = true;
      } catch (e) {
        debugPrint('Erro ao restaurar usuário: $e');
        logout();
      }
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _api.post('/auth/login', {
        'email': email,
        'password': password,
      });

      final token = response['token'];
      final userData = response['user'];
      final refreshToken = response['refreshToken'];

      await _storage.setToken(token);
      await _storage.setUser(jsonEncode(userData));
      if (refreshToken != null) {
        await _storage.setRefreshToken(refreshToken);
      }

      currentUser.value = User.fromJson(userData);
      isLoggedIn.value = true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      final response = await _api.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
      });

      final token = response['token'];
      final userData = response['user'];
      final refreshToken = response['refreshToken'];

      await _storage.setToken(token);
      await _storage.setUser(jsonEncode(userData));
      if (refreshToken != null) {
        await _storage.setRefreshToken(refreshToken);
      }

      currentUser.value = User.fromJson(userData);
      isLoggedIn.value = true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    // Clear auth credentials
    await _storage.removeToken();
    await _storage.removeUser();
    await _storage.removeRefreshToken();

    // Clear user-scoped local data (mood entries cache)
    await DatabaseService().clearAllData();

    // Reset reactive controller state if registered
    if (Get.isRegistered<MoodController>()) {
      final mc = Get.find<MoodController>();
      mc.todayEntries.clear();
      mc.recentEntries.clear();
      mc.isReflectionLoading.value = false;
    }

    currentUser.value = null;
    isLoggedIn.value = false;
  }
}
