import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../config/theme.dart';

class ChartPie extends StatefulWidget {
  final Map<int, int> distribution;

  const ChartPie({super.key, required this.distribution});

  @override
  State<ChartPie> createState() => _ChartPieState();
}

class _ChartPieState extends State<ChartPie> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.distribution.isEmpty) {
      return Center(
        child: Text(
          'Sem dados',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    final total = widget.distribution.values.fold<int>(
      0,
      (sum, count) => sum + count,
    );

    return SizedBox(
      height: 200.h,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: widget.distribution.entries.map((e) {
            final isTouched =
                widget.distribution.keys.toList().indexOf(e.key) ==
                touchedIndex;
            final percentage = (e.value / total * 100).toStringAsFixed(0);

            return PieChartSectionData(
              color: _getColor(e.key),
              value: e.value.toDouble(),
              title: '$percentage%',
              radius: isTouched ? 60 : 50,
              titleStyle: TextStyle(
                fontSize: isTouched ? 16.sp : 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 2,
                  ),
                ],
              ),
              badgeWidget: isTouched ? _buildBadge(e.key) : null,
              badgePositionPercentageOffset: 1.3,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBadge(int moodLevel) {
    String emoji;
    switch (moodLevel) {
      case 1:
        emoji = '😢';
        break;
      case 2:
        emoji = '😔';
        break;
      case 3:
        emoji = '😐';
        break;
      case 4:
        emoji = '😊';
        break;
      case 5:
        emoji = '😄';
        break;
      default:
        emoji = '😐';
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
        ],
      ),
      child: Text(emoji, style: TextStyle(fontSize: 20.sp)),
    );
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
