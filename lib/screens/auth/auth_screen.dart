import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/auth_controller.dart';
import '../../config/theme.dart';
import '../../widgets/mood_button.dart';
import '../../widgets/mood_card.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              SizedBox(height: 24.h),

              // Header
              Column(
                children: [
                  Icon(Icons.psychology, size: 48.sp, color: AppColors.primary),
                  SizedBox(height: 8.h),
                  Text(
                    'MoodTrack',
                    style: AppTextStyles.h1.copyWith(fontSize: 24.sp),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Tabs
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: const [
                      Tab(text: 'Entrar'),
                      Tab(text: 'Cadastrar'),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Tab Views
              Expanded(
                child: TabBarView(
                  children: [
                    // Login Tab
                    SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        children: [
                          MoodCard(
                            child: Column(
                              children: [
                                TextField(
                                  controller: controller.emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Obx(
                                  () => TextField(
                                    controller: controller.passwordController,
                                    obscureText:
                                        !controller.isPasswordVisible.value,
                                    decoration: InputDecoration(
                                      labelText: 'Senha',
                                      prefixIcon: Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          controller.isPasswordVisible.value
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed:
                                            controller.togglePasswordVisibility,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                SizedBox(
                                  width: double.infinity,
                                  child: Obx(
                                    () => controller.isLoading.value
                                        ? Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : MoodButton(
                                            label: 'Entrar',
                                            onPressed: controller.login,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => _showForgotPasswordDialog(context),
                            child: Text(
                              'Esqueci a senha',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Register Tab
                    SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        children: [
                          MoodCard(
                            child: Column(
                              children: [
                                TextField(
                                  controller: controller.nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Nome',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                TextField(
                                  controller: controller.emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Obx(
                                  () => TextField(
                                    controller: controller.passwordController,
                                    obscureText:
                                        !controller.isPasswordVisible.value,
                                    decoration: InputDecoration(
                                      labelText: 'Senha',
                                      prefixIcon: Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          controller.isPasswordVisible.value
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed:
                                            controller.togglePasswordVisibility,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Obx(
                                  () => TextField(
                                    controller:
                                        controller.confirmPasswordController,
                                    obscureText:
                                        !controller.isPasswordVisible.value,
                                    decoration: InputDecoration(
                                      labelText: 'Confirmar Senha',
                                      prefixIcon: Icon(Icons.lock_outline),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                Row(
                                  children: [
                                    Obx(
                                      () => Checkbox(
                                        value: controller.isTermsAccepted.value,
                                        onChanged:
                                            controller.toggleTermsAcceptance,
                                        activeColor: AppColors.primary,
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _showTermsModal(context),
                                        child: Text.rich(
                                          TextSpan(
                                            text: 'Li e aceito os ',
                                            style: AppTextStyles.body.copyWith(
                                              fontSize: 12.sp,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'Termos de Uso',
                                                style: AppTextStyles.body
                                                    .copyWith(
                                                      fontSize: 12.sp,
                                                      color: AppColors.primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                SizedBox(
                                  width: double.infinity,
                                  child: Obx(
                                    () => controller.isLoading.value
                                        ? Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : MoodButton(
                                            label: 'Cadastrar',
                                            onPressed:
                                                controller.isTermsAccepted.value
                                                ? controller.register
                                                : null,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Disclaimer
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  '⚠️ Este app não substitui acompanhamento profissional.\nEm caso de crise, ligue 188 (CVV).',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTermsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Termos de Uso e Privacidade', style: AppTextStyles.h1),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTermItem(
                '⚠️ Aviso Importante',
                'Este aplicativo NÃO substitui o acompanhamento profissional de psicólogos ou psiquiatras.',
              ),
              _buildTermItem(
                '🏥 Diagnósticos',
                'O MoodTrack não realiza diagnósticos médicos. As reflexões da IA são apenas para suporte emocional e autoconhecimento.',
              ),
              _buildTermItem(
                '🆘 Em caso de crise',
                'Se você estiver em perigo ou pensando em se machucar, ligue imediatamente para o CVV (188) ou procure um hospital.',
              ),
              _buildTermItem(
                '🔒 Privacidade',
                'Seus dados são armazenados localmente no seu dispositivo. A IA processa suas entradas de forma anônima.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendi', style: TextStyle(color: AppColors.primary)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildTermItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(content, style: AppTextStyles.body.copyWith(fontSize: 14)),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    final controller = Get.find<AuthController>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Recuperar Senha', style: AppTextStyles.h1),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Digite seu email para receber as instruções de recuperação.',
              style: AppTextStyles.body,
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Obx(
            () => TextButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.resetPassword(emailController.text),
              child: controller.isLoading.value
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Enviar', style: TextStyle(color: AppColors.primary)),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
