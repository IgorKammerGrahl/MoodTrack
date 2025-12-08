import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../config/theme.dart';

class ChartLine extends StatelessWidget {
  final List<MoodEntry> entries;

  const ChartLine({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.h),
          child: Text(
            'Adicione registros de humor para ver gráficos',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Sort entries by date
    final sortedEntries = entries.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return SizedBox(
      height: 200.h,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.textSecondary.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  if (value < 1 || value > 5) return SizedBox.shrink();
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  // Show label every ~5 days or first/last
                  if (index < 0 || index >= sortedEntries.length) {
                    return SizedBox.shrink();
                  }

                  final shouldShow =
                      index == 0 ||
                      index == sortedEntries.length - 1 ||
                      index % 5 == 0;

                  if (!shouldShow) return SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('dd/MM').format(sortedEntries[index].date),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  final entry = sortedEntries[spot.x.toInt()];
                  return LineTooltipItem(
                    '${DateFormat('dd/MM/yyyy').format(entry.date)}\n${entry.emoji} ${entry.moodDescription}',
                    TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  );
                }).toList();
              },
            ),
            touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
              // Optional: Add haptic feedback or other interactions
            },
            handleBuiltInTouches: true,
          ),
          lineBarsData: [
            LineChartBarData(
              spots: sortedEntries.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.moodLevel.toDouble());
              }).toList(),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF6B6B), // Red (low mood)
                  Color(0xFFFFD93D), // Yellow (neutral)
                  Color(0xFF6BCF7F), // Green (high mood)
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: _getMoodColor(spot.y.toInt()),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFF6B6B).withValues(alpha: 0.1),
                    Color(0xFFFFD93D).withValues(alpha: 0.1),
                    Color(0xFF6BCF7F).withValues(alpha: 0.1),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ],
          minY: 0,
          maxY: 6,
        ),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      ),
    );
  }

  Color _getMoodColor(int moodLevel) {
    switch (moodLevel) {
      case 1:
        return Color(0xFFFF6B6B); // Red
      case 2:
        return Color(0xFFFFAA6B); // Orange
      case 3:
        return Color(0xFFFFD93D); // Yellow
      case 4:
        return Color(0xFF95E1A4); // Light green
      case 5:
        return Color(0xFF6BCF7F); // Green
      default:
        return AppColors.primary;
    }
  }
}
