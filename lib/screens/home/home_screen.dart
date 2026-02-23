import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../controllers/mood_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../services/auth_service.dart';
import '../../domain/mood_question_rules.dart';
import '../../widgets/mood_card.dart';
import '../../widgets/mood_button.dart';
import '../../widgets/mood_emoji_button.dart';
import '../../widgets/timeline_horizontal.dart';
import '../chat/ai_chat_screen.dart';
import '../insights/insights_screen.dart';
import 'main_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final MoodController moodController;
  late final AuthController authController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    moodController = Get.find<MoodController>();
    authController = Get.find<AuthController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat(
                            'EEEE, d MMM',
                            'pt_BR',
                          ).format(DateTime.now()),
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
                  // Streak display
                  Obx(() {
                    final streak = moodController.currentStreak.value;
                    if (streak >= 1) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
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
                      onPressed: () => _showLogoutConfirmation(),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // Dynamic Content
              Obx(() {
                if (moodController.todayEntries.isNotEmpty && !_isEditing) {
                  return _buildRegisteredView();
                } else {
                  return _buildRegistrationView();
                }
              }),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisteredView() {
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
              if (latestEntry.note != null && latestEntry.note!.isNotEmpty) ...[
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
                Obx(() {
                  if (moodController.isReflectionLoading.value) {
                    return Center(
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
                    );
                  } else {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Text(
                        'Reflexão indisponível no momento.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13.sp,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  }
                }),
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
                  setState(() => _isEditing = true);
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
  }

  Widget _buildRegistrationView() {
    return Column(
      children: [
        // Mood Input Section
        MoodCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Como você está agora?',
                    style: AppTextStyles.h1.copyWith(fontSize: 20.sp),
                  ),
                  if (_isEditing)
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => setState(() => _isEditing = false),
                    ),
                ],
              ),
              SizedBox(height: 24.h),

              // Emojis
              Obx(
                () => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildEmojiOption(
                        moodController,
                        1,
                        '😢',
                        'Mal',
                        Color(0xFFFFC1C1),
                      ),
                      SizedBox(width: 12.w),
                      _buildEmojiOption(
                        moodController,
                        2,
                        '😔',
                        'Triste',
                        Color(0xFFFFD4A3),
                      ),
                      SizedBox(width: 12.w),
                      _buildEmojiOption(
                        moodController,
                        3,
                        '😐',
                        'Neutro',
                        Color(0xFFE8E8E8),
                      ),
                      SizedBox(width: 12.w),
                      _buildEmojiOption(
                        moodController,
                        4,
                        '😊',
                        'Bem',
                        Color(0xFFB8E6D5),
                      ),
                      SizedBox(width: 12.w),
                      _buildEmojiOption(
                        moodController,
                        5,
                        '😄',
                        'Ótimo',
                        Color(0xFFA8D5FF),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Contextual Questions (Objective 4)
              Obx(() {
                final mood = moodController.selectedMoodLevel.value;
                if (mood == 0) return const SizedBox.shrink();

                final questions = MoodQuestionRules.getQuestions(mood);
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: questions.map((q) {
                      return ActionChip(
                        label: Text(
                          q,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        onPressed: () {
                          final current = moodController.noteController.text;
                          if (current.isEmpty) {
                            moodController.noteController.text = q;
                          } else {
                            moodController.noteController.text = '$current\n$q';
                          }
                        },
                      );
                    }).toList(),
                  ),
                );
              }),

              // Note Input
              TextField(
                controller: moodController.noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Quer adicionar uma nota? (opcional)',
                  alignLabelWithHint: true,
                ),
              ),

              SizedBox(height: 24.h),

              // Submit Button
              Obx(() {
                if (moodController.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                return SizedBox(
                  width: double.infinity,
                  child: MoodButton(
                    label: _isEditing ? 'Atualizar Humor' : 'Registrar Humor',
                    onPressed: () async {
                      await moodController.addEntry();
                      if (_isEditing) {
                        setState(() => _isEditing = false);
                      }
                    },
                  ),
                );
              }),
            ],
          ),
        ),

        SizedBox(height: 24.h),

        // AI Reflection Teaser
        MoodCard(
          backgroundColor: AppColors.secondary.withValues(alpha: 0.3),
          border: Border.all(color: AppColors.secondary),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.primary, size: 32.sp),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reflexão do Dia',
                      style: AppTextStyles.h1.copyWith(fontSize: 16.sp),
                    ),
                    Text(
                      'Continue registrando para desbloquear insights da IA.',
                      style: AppTextStyles.body.copyWith(fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiOption(
    MoodController controller,
    int level,
    String emoji,
    String label,
    Color color,
  ) {
    return MoodEmojiButton(
      emoji: emoji,
      label: label,
      color: color,
      isSelected: controller.selectedMoodLevel.value == level,
      onTap: () => controller.selectMood(level),
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
