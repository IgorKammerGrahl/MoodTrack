import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/theme.dart';
import '../../widgets/mood_button.dart';
import '../auth/auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Bem-vindo ao MoodTrack',
      'description':
          'Seu diário emocional inteligente para acompanhar seu bem-estar.',
      'icon': 'psychology',
    },
    {
      'title': 'Registre seu Humor',
      'description':
          'Acompanhe como você se sente diariamente com apenas alguns toques.',
      'icon': 'mood',
    },
    {
      'title': 'Receba Insights',
      'description':
          'Nossa IA analisa seus registros e oferece reflexões personalizadas.',
      'icon': 'lightbulb',
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.off(() => const AuthScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.all(32.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(32.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIcon(_pages[index]['icon']!),
                            size: 80.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 48.h),
                        Text(
                          _pages[index]['title']!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h1.copyWith(fontSize: 28.sp),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          _pages[index]['description']!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: _currentPage == index ? 24.w : 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: SizedBox(
                width: double.infinity,
                child: MoodButton(
                  label: _currentPage == _pages.length - 1
                      ? 'Começar'
                      : 'Próximo',
                  onPressed: _nextPage,
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Skip Button
            if (_currentPage < _pages.length - 1)
              TextButton(
                onPressed: () => Get.off(() => const AuthScreen()),
                child: Text(
                  'Pular',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              SizedBox(height: 48.h), // Placeholder to keep layout stable

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'psychology':
        return Icons.psychology;
      case 'mood':
        return Icons.mood;
      case 'lightbulb':
        return Icons.lightbulb_outline;
      default:
        return Icons.circle;
    }
  }
}
