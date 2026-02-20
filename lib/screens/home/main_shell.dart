import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/theme.dart';
import '../../core/network_status_service.dart';
import 'home_screen.dart';
import '../chat/ai_chat_screen.dart';
import '../insights/insights_screen.dart';
import '../settings/settings_screen.dart';

/// Main navigation shell with IndexedStack for persistent screen state.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    AIChatScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Offline indicator banner
          _buildOfflineBanner(),

          // Content with IndexedStack
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _pages),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat IA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Insights',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  Widget _buildOfflineBanner() {
    if (!Get.isRegistered<NetworkStatusService>()) {
      return const SizedBox.shrink();
    }

    final networkService = Get.find<NetworkStatusService>();
    return Obx(() {
      if (networkService.isOnline.value) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        color: Colors.orange.shade700,
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white, size: 18.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Sem conexão — dados serão sincronizados ao reconectar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
