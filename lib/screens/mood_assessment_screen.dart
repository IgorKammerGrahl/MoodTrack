import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import 'home/home_screen.dart';

class MoodAssessmentScreen extends StatelessWidget {
  const MoodAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Esta tela foi movida para a Home', style: AppTextStyles.h1),
            ElevatedButton(
              onPressed: () => Get.offAll(() => const HomeScreen()),
              child: Text('Ir para Home'),
            ),
          ],
        ),
      ),
    );
  }
}
