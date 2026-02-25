import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../controllers/mood_controller.dart';
import '../../screens/home/main_shell.dart';
import '../../screens/chat/ai_chat_screen.dart';
import '../../screens/insights/insights_screen.dart';
import '../mood_card.dart';
import '../mood_button.dart';
import '../timeline_horizontal.dart';

class RegisteredMoodView extends StatelessWidget {
  const RegisteredMoodView({super.key});

  @override
  Widget build(BuildContext context) {
    final moodController = Get.find<MoodController>();

    return Obx(() {
      if (moodController.todayEntries.isEmpty) return const SizedBox.shrink();
      final latestEntry = moodController.todayEntries.first;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          MoodCard(
            child: Column(
              children: [
                Text(
                  'Status: Humor ${latestEntry.emoji}',
                  style: AppTextStyles.h1.copyWith(fontSize: 20.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Atualizado às ${DateFormat('HH:mm').format(latestEntry.date)}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
                if (latestEntry.note != null &&
                    latestEntry.note!.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Text(
                    '"${latestEntry.note}"',
                    style: AppTextStyles.body.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Timeline
          Text(
            'Sua jornada hoje',
            style: AppTextStyles.h1.copyWith(fontSize: 18.sp),
          ),
          SizedBox(height: 16.h),
          TimelineHorizontal(entries: moodController.todayEntries),

          SizedBox(height: 24.h),

          // AI Reflection
          MoodCard(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppColors.primary),
                    SizedBox(width: 8.w),
                    Text(
                      'Reflexão Personalizada',
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                if (latestEntry.aiReflection != null) ...[
                  Text(latestEntry.aiReflection!, style: AppTextStyles.body),
                  if (latestEntry.reflectionGeneratedAt != null) ...[
                    SizedBox(height: 12.h),
                    Text(
                      'Gerada às ${DateFormat('HH:mm').format(latestEntry.reflectionGeneratedAt!)}',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ] else ...[
                  if (moodController.isReflectionLoading.value)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'IA gerando reflexão...',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Text(
                        'Reflexão indisponível no momento.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13.sp,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Actions
          Row(
            children: [
              Expanded(
                child: MoodButton(
                  label: 'Atualizar Humor',
                  onPressed: () {
                    moodController.selectMood(latestEntry.moodLevel);
                    moodController.noteController.text = latestEntry.note ?? '';
                    moodController.isEditingEntry.value = true;
                  },
                  style: MoodButtonStyle.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: MoodButton(
                  label: 'Chat IA',
                  onPressed: () {
                    if (Get.isRegistered<MainShellController>()) {
                      Get.find<MainShellController>().changeTab(1);
                    } else {
                      Get.to(() => const AIChatScreen());
                    }
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: MoodButton(
                  label: 'Insights',
                  onPressed: () {
                    if (Get.isRegistered<MainShellController>()) {
                      Get.find<MainShellController>().changeTab(2);
                    } else {
                      Get.to(() => const InsightsScreen());
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
