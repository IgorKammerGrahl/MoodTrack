import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../theme/app_theme.dart';

/// Splashscreen - Primeira tela do app (Stateless Widget)
/// Exibe logo e frase motivacional por 3 segundos
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Navega automaticamente após 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Ícone do app
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                size: 80,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 32),

            // Nome do app
            Text(
              'MoodTrack',
              style: AppTextStyles.h1.copyWith(
                fontSize: 32,
                color: AppColors.text,
              ),
            ),

            const SizedBox(height: 8),

            // Subtítulo
            Text(
              'seu diário emocional',
              style: AppTextStyles.body.copyWith(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 48),

            // Frase motivacional
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                '"Entender o que sentimos é o\nprimeiro passo para cuidar de si"',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Indicador de carregamento
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
