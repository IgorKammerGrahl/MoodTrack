import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../config/constants.dart';

const String _onboardingKey = 'has_seen_onboarding';
const String _refreshTokenKey = 'refresh_token';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Token
  Future<void> setToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(AppConstants.tokenKey);
  }

  Future<void> removeToken() async {
    await _prefs.remove(AppConstants.tokenKey);
  }

  // User Data
  Future<void> setUser(String userData) async {
    await _prefs.setString(AppConstants.userKey, userData);
  }

  String? getUser() {
    return _prefs.getString(AppConstants.userKey);
  }

  Future<void> removeUser() async {
    await _prefs.remove(AppConstants.userKey);
  }

  // Onboarding
  bool get hasSeenOnboarding => _prefs.getBool(_onboardingKey) ?? false;

  Future<void> setHasSeenOnboarding() async {
    await _prefs.setBool(_onboardingKey, true);
  }

  // Refresh Token
  Future<void> setRefreshToken(String token) async {
    await _prefs.setString(_refreshTokenKey, token);
  }

  String? getRefreshToken() {
    return _prefs.getString(_refreshTokenKey);
  }

  Future<void> removeRefreshToken() async {
    await _prefs.remove(_refreshTokenKey);
  }
}
