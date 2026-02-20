import 'package:get/get.dart';
import '../models/user.dart';
import '../controllers/mood_controller.dart';
import '../repositories/auth_repository.dart';
import '../repositories/mood_repository.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  final AuthRepository _authRepo = AuthRepository();
  final StorageService _storage = Get.find<StorageService>();

  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  void _loadUserFromStorage() {
    final user = _authRepo.loadUserFromStorage(_storage);
    if (user != null) {
      currentUser.value = user;
      isLoggedIn.value = true;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final user = await _authRepo.login(_storage, email, password);
      currentUser.value = user;
      isLoggedIn.value = true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      final user = await _authRepo.register(_storage, name, email, password);
      currentUser.value = user;
      isLoggedIn.value = true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    // Clear auth credentials
    await _authRepo.clearCredentials(_storage);

    // Clear user-scoped local data (mood entries cache)
    await MoodRepository().clearAllData();

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
