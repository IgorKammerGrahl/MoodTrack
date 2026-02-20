import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/theme.dart';
import '../../controllers/insights_controller.dart';
import '../../widgets/mood_card.dart';
import '../../widgets/chart_line.dart';
import '../../widgets/chart_pie.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InsightsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Insights',
          style: AppTextStyles.h1.copyWith(fontSize: 18.sp),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.monthlyEntries.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.insights,
                    size: 64.sp,
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Sem dados suficientes',
                    style: AppTextStyles.h1.copyWith(fontSize: 18.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Adicione registros de humor para ver seus insights',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Average Mood Summary
              MoodCard(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _getAverageMoodEmoji(controller.averageMood.value),
                          style: TextStyle(fontSize: 32.sp),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Humor Médio',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${controller.averageMood.value.toStringAsFixed(1)}/5',
                              style: AppTextStyles.h1.copyWith(fontSize: 24.sp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Monthly Trend
              Text(
                'Evolução Mensal',
                style: AppTextStyles.h1.copyWith(fontSize: 16.sp),
              ),
              SizedBox(height: 16.h),
              MoodCard(
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: ChartLine(entries: controller.monthlyEntries),
                ),
              ),

              SizedBox(height: 32.h),

              // Mood Distribution
              Text(
                'Distribuição de Humor',
                style: AppTextStyles.h1.copyWith(fontSize: 16.sp),
              ),
              SizedBox(height: 16.h),
              MoodCard(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ChartPie(
                          distribution: controller.moodDistribution,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: controller.moodDistribution.entries.map((
                            e,
                          ) {
                            final percentage = controller.getPercentage(e.key);
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12.w,
                                    height: 12.w,
                                    decoration: BoxDecoration(
                                      color: _getColor(e.key),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      '${percentage.toStringAsFixed(0)}%',
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Patterns
              Text(
                'Padrões Identificados',
                style: AppTextStyles.h1.copyWith(fontSize: 16.sp),
              ),
              SizedBox(height: 16.h),

              // Row 1: Best Day and Best Time
              Row(
                children: [
                  Expanded(
                    child: _buildPatternCard(
                      icon: '📅',
                      title: 'Melhor Dia',
                      value:
                          controller.bestDayOfWeek.value ??
                          'Dados insuficientes',
                      color: Colors.blue,
                      hasData: controller.bestDayOfWeek.value != null,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildPatternCard(
                      icon: '⏰',
                      title: 'Melhor Horário',
                      value:
                          controller.bestTimeOfDay.value ??
                          'Dados insuficientes',
                      color: Colors.orange,
                      hasData: controller.bestTimeOfDay.value != null,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Row 2: Emotional Cycle
              _buildPatternCard(
                icon: '🔄',
                title: 'Ciclo Emocional',
                value: controller.emotionalCycleDays.value != null
                    ? '~${controller.emotionalCycleDays.value} dias'
                    : 'Sem padrão detectado',
                color: Colors.purple,
                hasData: controller.emotionalCycleDays.value != null,
                fullWidth: true,
              ),

              SizedBox(height: 32.h),

              // Activity Correlations
              Text(
                'Correlações com Atividades',
                style: AppTextStyles.h1.copyWith(fontSize: 16.sp),
              ),
              SizedBox(height: 16.h),

              Obx(() {
                if (controller.activityCorrelations.isEmpty) {
                  return MoodCard(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 48.sp,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Adicione mais notas para identificar correlações',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: controller.activityCorrelations.map((activity) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _buildActivityCard(activity),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActivityCard(activity) {
    final isPositive = activity.impactPercentage > 0;
    final color = isPositive ? Colors.green : Colors.red;

    return MoodCard(
      backgroundColor: color.withValues(alpha: 0.05),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Text(activity.emoji, style: TextStyle(fontSize: 32.sp)),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.displayName,
                    style: AppTextStyles.h1.copyWith(fontSize: 16.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${activity.occurrences} vezes',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  '${activity.impactPercentage > 0 ? '+' : ''}${activity.impactPercentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: color,
                  size: 24.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternCard({
    required String icon,
    required String title,
    required String value,
    required Color color,
    required bool hasData,
    bool fullWidth = false,
  }) {
    return MoodCard(
      backgroundColor: hasData
          ? color.withValues(alpha: 0.05)
          : Colors.grey.withValues(alpha: 0.05),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: fullWidth
            ? Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: (hasData ? color : Colors.grey).withValues(
                        alpha: 0.1,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Text(icon, style: TextStyle(fontSize: 24.sp)),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          value,
                          style: AppTextStyles.h1.copyWith(
                            fontSize: 16.sp,
                            color: hasData
                                ? AppColors.text
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: (hasData ? color : Colors.grey).withValues(
                        alpha: 0.1,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Text(icon, style: TextStyle(fontSize: 24.sp)),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    value,
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 14.sp,
                      color: hasData ? AppColors.text : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }

  String _getAverageMoodEmoji(double avgMood) {
    if (avgMood >= 4.5) return '😄';
    if (avgMood >= 3.5) return '😊';
    if (avgMood >= 2.5) return '😐';
    if (avgMood >= 1.5) return '😔';
    return '😢';
  }

  Color _getColor(int level) {
    switch (level) {
      case 1:
        return Color(0xFFFFC1C1);
      case 2:
        return Color(0xFFFFD4A3);
      case 3:
        return Color(0xFFE8E8E8);
      case 4:
        return Color(0xFFB8E6D5);
      case 5:
        return Color(0xFFA8D5FF);
      default:
        return AppColors.primary;
    }
  }
}
