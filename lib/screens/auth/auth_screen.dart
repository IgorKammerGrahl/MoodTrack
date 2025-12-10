import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/auth_controller.dart';
import '../../config/theme.dart';
import '../../widgets/mood_button.dart';
import '../../widgets/animated_entry.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());

    return Scaffold(
      // Gradient Background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.primary.withValues(alpha: 0.1),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: DefaultTabController(
            length: 2,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(height: 32.h),

                      // Animated Header
                      AnimatedEntry(
                        delay: Duration(milliseconds: 200),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.psychology,
                                size: 48.sp,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'MoodTrack',
                              style: AppTextStyles.h1.copyWith(
                                fontSize: 28.sp,
                                color: AppColors.primary,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Seu diário emocional inteligente',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Modern Tabs
                      AnimatedEntry(
                        delay: Duration(milliseconds: 400),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Container(
                            height: 56.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TabBar(
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              dividerColor: Colors.transparent,
                              labelColor: Colors.white,
                              unselectedLabelColor: AppColors.textSecondary,
                              labelStyle: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              splashBorderRadius: BorderRadius.circular(28),
                              tabs: const [
                                Tab(text: 'Entrar'),
                                Tab(text: 'Cadastrar'),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 32.h),
                    ],
                  ),
                ),

                // Tab Views (Fill remaining space)
                SliverFillRemaining(
                  child: TabBarView(
                    children: [
                      // Login Tab
                      _buildLoginTab(context, controller),

                      // Register Tab
                      _buildRegisterTab(context, controller),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTab(BuildContext context, AuthController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          AnimatedEntry(
            delay: Duration(milliseconds: 600),
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildTextField(
                    controller: controller.emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    inputType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16.h),
                  Obx(
                    () => _buildTextField(
                      controller: controller.passwordController,
                      label: 'Senha',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isVisible: controller.isPasswordVisible.value,
                      onVisibilityToggle: controller.togglePasswordVisibility,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showForgotPasswordDialog(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Esqueci a senha',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
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
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
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
          ),
          SizedBox(height: 24.h),
          _buildDisclaimer(),
          SizedBox(height: 24.h), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildRegisterTab(BuildContext context, AuthController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          AnimatedEntry(
            delay: Duration(milliseconds: 600),
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildTextField(
                    controller: controller.nameController,
                    label: 'Nome',
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: 16.h),
                  _buildTextField(
                    controller: controller.emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    inputType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16.h),
                  Obx(
                    () => _buildTextField(
                      controller: controller.passwordController,
                      label: 'Senha',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isVisible: controller.isPasswordVisible.value,
                      onVisibilityToggle: controller.togglePasswordVisibility,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Obx(
                    () => _buildTextField(
                      controller: controller.confirmPasswordController,
                      label: 'Confirmar Senha',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isVisible: controller.isPasswordVisible.value,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      SizedBox(
                        height: 24.h,
                        width: 24.h,
                        child: Obx(
                          () => Checkbox(
                            value: controller.isTermsAccepted.value,
                            onChanged: controller.toggleTermsAcceptance,
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
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
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 12.sp,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    child: Obx(
                      () => controller.isLoading.value
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            )
                          : MoodButton(
                              label: 'Criar conta',
                              onPressed: controller.isTermsAccepted.value
                                  ? controller.register
                                  : null,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),
          _buildDisclaimer(),
          SizedBox(height: 24.h), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Text(
        '⚠️ Este app não substitui acompanhamento profissional.\nEm caso de crise, ligue 188 (CVV).',
        textAlign: TextAlign.center,
        style: AppTextStyles.body.copyWith(
          fontSize: 10.sp,
          color: AppColors.textSecondary.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityToggle,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isVisible,
        keyboardType: inputType,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }

  void _showTermsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            SizedBox(height: 16.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Text(
                'Termos de Uso e Privacidade',
                style: AppTextStyles.h1.copyWith(fontSize: 20.sp),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
            ),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: SizedBox(
                width: double.infinity,
                child: MoodButton(
                  label: 'Entendi',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              content,
              style: AppTextStyles.body.copyWith(fontSize: 14.sp, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    final controller = Get.find<AuthController>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_reset, size: 48.sp, color: AppColors.primary),
              SizedBox(height: 16.h),
              Text(
                'Recuperar Senha',
                style: AppTextStyles.h1.copyWith(fontSize: 20.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                'Digite seu email para receber as instruções.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 24.h),
              _buildTextField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                inputType: TextInputType.emailAddress,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Obx(
                      () => MoodButton(
                        label: 'Enviar',
                        isLoading: controller.isLoading.value,
                        onPressed: () =>
                            controller.resetPassword(emailController.text),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
