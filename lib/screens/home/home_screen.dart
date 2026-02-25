import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/theme.dart';
import '../../controllers/mood_controller.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/home/registered_mood_view.dart';
import '../../widgets/home/mood_registration_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moodController = Get.find<MoodController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),

              const HomeHeader(),

              SizedBox(height: 32.h),

              // Dynamic Content
              Obx(() {
                if (moodController.todayEntries.isNotEmpty &&
                    !moodController.isEditingEntry.value) {
                  return const RegisteredMoodView();
                } else {
                  return const MoodRegistrationForm();
                }
              }),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
