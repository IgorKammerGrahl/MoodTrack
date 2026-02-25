import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../controllers/mood_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../services/auth_service.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final moodController = Get.find<MoodController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, d MMM', 'pt_BR').format(DateTime.now()),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
              Obx(
                () => Text(
                  'Olá, ${authController.userName.value.isNotEmpty ? authController.userName.value : "Visitante"}',
                  style: AppTextStyles.h1.copyWith(fontSize: 24.sp),
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          final streak = moodController.currentStreak.value;
          if (streak >= 1) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🔥', style: TextStyle(fontSize: 16.sp)),
                  SizedBox(width: 4.w),
                  Text(
                    '$streak ${streak == 1 ? "dia" : "dias"}',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        SizedBox(width: 8.w),
        CircleAvatar(
          backgroundColor: AppColors.secondary,
          child: IconButton(
            icon: Icon(Icons.logout, color: AppColors.primary),
            onPressed: _showLogoutConfirmation,
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmation() {
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
              Get.find<AuthService>().logout();
            },
            child: Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
