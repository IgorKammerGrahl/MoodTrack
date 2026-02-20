import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'config/theme.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';
import 'core/network_status_service.dart';
import 'controllers/mood_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/settings_controller.dart';
import 'screens/home/main_shell.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/auth_screen.dart';

/// Função principal - Ponto de entrada do aplicativo
void main() async {
  // Necessário para usar SharedPreferences e outros plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa formatação de datas em português
  await initializeDateFormatting('pt_BR', null);

  // Initialize Services
  await Get.putAsync(() => StorageService().init());
  Get.put(AuthService());
  Get.put(NetworkStatusService());

  // Initialize Controllers
  Get.put(AuthController());
  Get.put(MoodController());
  Get.put(SettingsController(), permanent: true);

  runApp(const MoodTrackApp());
}

/// Widget principal do aplicativo
class MoodTrackApp extends StatelessWidget {
  const MoodTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configuração de responsividade (baseado no design 375x812 - iPhone X)
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'MoodTrack',
          debugShowCheckedModeBanner: false,

          // Tema do aplicativo
          theme: AppTheme.lightTheme,

          // Configurações de navegação e locale
          locale: const Locale('pt', 'BR'),
          fallbackLocale: const Locale('en', 'US'),

          // Tela inicial
          home: const InitialScreen(),
        );
      },
    );
  }
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<AuthService>(
      builder: (auth) {
        if (auth.isLoggedIn.value) {
          return const MainShell();
        } else {
          // Show onboarding only on first launch
          final storage = Get.find<StorageService>();
          if (storage.hasSeenOnboarding) {
            return const AuthScreen();
          }
          return const OnboardingScreen();
        }
      },
    );
  }
}
