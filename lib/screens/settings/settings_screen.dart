import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/theme.dart';
import '../../controllers/settings_controller.dart';
import '../../services/auth_service.dart';
import '../../widgets/mood_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final authService = Get.find<AuthService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Ajustes',
          style: AppTextStyles.h1.copyWith(fontSize: 18.sp),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Text('Perfil', style: AppTextStyles.h1.copyWith(fontSize: 16.sp)),
            SizedBox(height: 16.h),
            MoodCard(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    authService.currentUser.value?.name
                            .substring(0, 1)
                            .toUpperCase() ??
                        'U',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  authService.currentUser.value?.name ?? 'Usuário',
                  style: AppTextStyles.h1.copyWith(fontSize: 16.sp),
                ),
                subtitle: Text(
                  authService.currentUser.value?.email ?? 'email@exemplo.com',
                  style: AppTextStyles.body.copyWith(fontSize: 12.sp),
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // Notifications Section
            Text(
              'Notificações',
              style: AppTextStyles.h1.copyWith(fontSize: 16.sp),
            ),
            SizedBox(height: 16.h),
            MoodCard(
              child: Column(
                children: [
                  // Daily Reminder
                  Obx(
                    () => SwitchListTile(
                      title: Text('Lembrete Diário', style: AppTextStyles.body),
                      subtitle: Text(
                        'Horário: ${controller.dailyReminderTime.value.format(context)}',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      value: controller.dailyReminderEnabled.value,
                      onChanged: controller.toggleDailyReminder,
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                  Obx(() {
                    if (controller.dailyReminderEnabled.value) {
                      return ListTile(
                        title: Text(
                          'Alterar Horário',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Icon(
                          Icons.access_time,
                          color: AppColors.primary,
                        ),
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: controller.dailyReminderTime.value,
                          );
                          if (picked != null) {
                            controller.updateDailyReminderTime(picked);
                          }
                        },
                      );
                    }
                    return SizedBox.shrink();
                  }),

                  Divider(),

                  // Weekly Insights
                  Obx(
                    () => SwitchListTile(
                      title: Text(
                        'Insights Semanais',
                        style: AppTextStyles.body,
                      ),
                      subtitle: Text(
                        'Dia: ${_getDayName(controller.weeklyInsightDay.value)}',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      value: controller.weeklyInsightEnabled.value,
                      onChanged: controller.toggleWeeklyInsight,
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                  Obx(() {
                    if (controller.weeklyInsightEnabled.value) {
                      return ListTile(
                        title: Text(
                          'Alterar Dia',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                        ),
                        onTap: () => _showDayPicker(context, controller),
                      );
                    }
                    return SizedBox.shrink();
                  }),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Accessibility Section
            Text(
              'Acessibilidade',
              style: AppTextStyles.h1.copyWith(fontSize: 16.sp),
            ),
            SizedBox(height: 16.h),
            MoodCard(
              child: Column(
                children: [
                  // Visual Difficulty Master Switch
                  Obx(
                    () => SwitchListTile(
                      title: Text(
                        'Tenho dificuldade visual',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Aumenta fonte e contraste automaticamente',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      value: controller.visualDifficulty.value,
                      onChanged: controller.toggleVisualDifficulty,
                      activeThumbColor: AppColors.primary,
                    ),
                  ),

                  Divider(),

                  // Font Size Slider
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Text(
                            'Tamanho da Fonte: ${(controller.fontSizeScale.value * 100).toInt()}%',
                            style: AppTextStyles.body,
                          ),
                        ),
                        Slider(
                          value: controller.fontSizeScale.value,
                          min: 0.8,
                          max: 1.5,
                          divisions: 7,
                          label:
                              '${(controller.fontSizeScale.value * 100).toInt()}%',
                          activeColor: AppColors.primary,
                          onChanged: controller.visualDifficulty.value
                              ? null // Disable if visual difficulty mode is on (optional, but good UX)
                              : controller.updateFontSize,
                        ),
                      ],
                    ),
                  ),

                  Divider(),

                  // High Contrast
                  Obx(
                    () => SwitchListTile(
                      title: Text('Alto Contraste', style: AppTextStyles.body),
                      value: controller.highContrast.value,
                      onChanged: controller.visualDifficulty.value
                          ? null
                          : controller.toggleHighContrast,
                      activeThumbColor: AppColors.primary,
                    ),
                  ),

                  Divider(),

                  // Dark Mode
                  Obx(
                    () => SwitchListTile(
                      title: Text('Modo Escuro', style: AppTextStyles.body),
                      value: controller.isDarkMode.value,
                      onChanged: controller.toggleTheme,
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Preferences
            Text(
              'Preferências',
              style: AppTextStyles.h1.copyWith(fontSize: 16.sp),
            ),
            SizedBox(height: 16.h),

            // Data & Privacy
            Text(
              'Dados e Privacidade',
              style: AppTextStyles.h1.copyWith(fontSize: 16.sp),
            ),
            SizedBox(height: 16.h),
            MoodCard(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.download, color: AppColors.text),
                    title: Text(
                      'Exportar Dados (CSV)',
                      style: AppTextStyles.body,
                    ),
                    onTap: controller.exportData,
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.delete_forever, color: Colors.red),
                    title: Text(
                      'Deletar Conta',
                      style: AppTextStyles.body.copyWith(color: Colors.red),
                    ),
                    onTap: controller.deleteAccount,
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: Text(
                        'Sair da conta',
                        style: AppTextStyles.h1.copyWith(fontSize: 18),
                      ),
                      content: Text(
                        'Tem certeza que deseja sair? Seus dados locais serão mantidos.',
                        style: AppTextStyles.body,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            authService.logout();
                          },
                          child: Text(
                            'Sair',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  side: BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Sair da Conta',
                  style: AppTextStyles.button.copyWith(color: Colors.red),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            Center(
              child: Text(
                'Versão 2.0.0',
                style: AppTextStyles.body.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int day) {
    const days = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo',
    ];
    // DateTime.monday is 1, so index is day - 1
    if (day >= 1 && day <= 7) {
      return days[day - 1];
    }
    return 'Domingo';
  }

  void _showDayPicker(BuildContext context, SettingsController controller) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(
          'Escolha o dia',
          style: AppTextStyles.h1.copyWith(fontSize: 18),
        ),
        children: List.generate(7, (index) {
          final day = index + 1;
          return SimpleDialogOption(
            onPressed: () {
              controller.updateWeeklyInsightDay(day);
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _getDayName(day),
                style: AppTextStyles.body.copyWith(
                  fontWeight: day == controller.weeklyInsightDay.value
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: day == controller.weeklyInsightDay.value
                      ? AppColors.primary
                      : AppColors.text,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
