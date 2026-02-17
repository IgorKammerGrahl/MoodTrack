import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';

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

      await _storage.setToken(token);
      await _storage.setUser(jsonEncode(userData));

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

      await _storage.setToken(token);
      await _storage.setUser(jsonEncode(userData));

      currentUser.value = User.fromJson(userData);
      isLoggedIn.value = true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.removeToken();
    await _storage.removeUser();
    currentUser.value = null;
    isLoggedIn.value = false;
  }
}
