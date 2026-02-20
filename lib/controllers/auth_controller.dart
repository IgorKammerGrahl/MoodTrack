import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../screens/home/main_shell.dart';
import '../utils/validators.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();

  final RxString userName = ''.obs; // Observable user name for UI
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isTermsAccepted = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to currentUser changes and update userName
    ever(_authService.currentUser, (user) {
      userName.value = user?.name ?? 'Visitante';
    });
    // Initialize userName from current user if already logged in
    userName.value = _authService.currentUser.value?.name ?? 'Visitante';
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleTermsAcceptance(bool? value) {
    isTermsAccepted.value = value ?? false;
  }

  Future<void> login() async {
    final emailError = Validators.validateEmail(emailController.text);
    final passwordError = Validators.validatePassword(passwordController.text);

    if (emailError != null) {
      Get.snackbar('Erro', emailError);
      return;
    }
    if (passwordError != null) {
      Get.snackbar('Erro', passwordError);
      return;
    }

    isLoading.value = true;
    try {
      await _authService.login(
        emailController.text.trim(),
        passwordController.text,
      );
      _onSuccess();
    } catch (e) {
      _onError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    final nameError = Validators.validateName(nameController.text);
    final emailError = Validators.validateEmail(emailController.text);
    final passwordError = Validators.validatePassword(passwordController.text);
    final confirmError = Validators.validateConfirmPassword(
      confirmPasswordController.text,
      passwordController.text,
    );

    if (nameError != null) {
      Get.snackbar('Erro', nameError);
      return;
    }
    if (emailError != null) {
      Get.snackbar('Erro', emailError);
      return;
    }
    if (passwordError != null) {
      Get.snackbar('Erro', passwordError);
      return;
    }
    if (confirmError != null) {
      Get.snackbar('Erro', confirmError);
      return;
    }

    if (!isTermsAccepted.value) {
      Get.snackbar('Erro', 'Você precisa aceitar os Termos de Uso');
      return;
    }

    isLoading.value = true;
    try {
      await _authService.register(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
      );
      _onSuccess();
    } catch (e) {
      _onError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String email) async {
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      Get.snackbar('Erro', emailError);
      return;
    }

    isLoading.value = true;
    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 2));
      Get.back(); // Close dialog
      Get.snackbar(
        'Sucesso',
        'Email de recuperação enviado para $email!',
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      _onError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void _onSuccess() {
    // Update userName from AuthService
    userName.value = _authService.currentUser.value?.name ?? 'Visitante';
    // Navigate to Home
    Get.offAll(() => const MainShell());
  }

  void _onError(Object e) {
    Get.snackbar(
      'Erro',
      'Falha na autenticação: ${e.toString()}',
      backgroundColor: Colors.red.withValues(alpha: 0.1),
      colorText: Colors.red,
    );
  }
}
