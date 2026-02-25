import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/theme.dart';
import '../../controllers/mood_controller.dart';
import '../mood_card.dart';
import '../mood_button.dart';
import '../mood_emoji_button.dart';

class MoodRegistrationForm extends StatelessWidget {
  const MoodRegistrationForm({super.key});

  static const List<String> availableTags = [
    'Trabalho',
    'Família',
    'Amigos',
    'Exercício',
    'Lazer',
    'Cansaço',
    'Ansiedade',
  ];

  @override
  Widget build(BuildContext context) {
    final moodController = Get.find<MoodController>();

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
                  Obx(() {
                    if (moodController.isEditingEntry.value) {
                      return IconButton(
                        icon: Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: () =>
                            moodController.isEditingEntry.value = false,
                      );
                    }
                    return const SizedBox.shrink();
                  }),
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
                        const Color(0xFFFFC1C1),
                      ),
                      SizedBox(width: 12.w),
                      _buildEmojiOption(
                        moodController,
                        2,
                        '😔',
                        'Triste',
                        const Color(0xFFFFD4A3),
                      ),
                      SizedBox(width: 12.w),
                      _buildEmojiOption(
                        moodController,
                        3,
                        '😐',
                        'Neutro',
                        const Color(0xFFE8E8E8),
                      ),
                      SizedBox(width: 12.w),
                      _buildEmojiOption(
                        moodController,
                        4,
                        '😊',
                        'Bem',
                        const Color(0xFFB8E6D5),
                      ),
                      SizedBox(width: 12.w),
                      _buildEmojiOption(
                        moodController,
                        5,
                        '😄',
                        'Ótimo',
                        const Color(0xFFA8D5FF),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Tags Section
              Obx(() {
                final mood = moodController.selectedMoodLevel.value;
                if (mood == 0) return const SizedBox.shrink();

                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'O que está influenciando isso?',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: availableTags.map((tag) {
                          final isSelected = moodController.selectedTags
                              .contains(tag);
                          return FilterChip(
                            label: Text(
                              tag,
                              style: AppTextStyles.body.copyWith(
                                fontSize: 12.sp,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.primary,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (_) => moodController.toggleTag(tag),
                            selectedColor: AppColors.primary,
                            checkmarkColor: Colors.white,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : AppColors.primary.withValues(alpha: 0.3),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }),

              // Note Input
              TextField(
                controller: moodController.noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Quer adicionar uma nota livre? (opcional)',
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
                final isEditing = moodController.isEditingEntry.value;
                return SizedBox(
                  width: double.infinity,
                  child: MoodButton(
                    label: isEditing ? 'Atualizar Humor' : 'Registrar Humor',
                    onPressed: () async {
                      await moodController.addEntry();
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
}
