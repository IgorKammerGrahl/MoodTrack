import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../config/theme.dart';

class TimelineHorizontal extends StatelessWidget {
  final List<MoodEntry> entries;

  const TimelineHorizontal({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'Nenhum registro hoje',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return SizedBox(
      height: 100.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final isFirst = index == 0;
          final isLast = index == entries.length - 1;

          return Row(
            children: [
              if (isFirst) SizedBox(width: 4.w),
              _buildTimelineItem(entry),
              if (!isLast)
                Container(width: 24.w, height: 2.h, color: AppColors.secondary),
              if (isLast) SizedBox(width: 4.w),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem(MoodEntry entry) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: entry.color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: entry.color, width: 2),
          ),
          child: Text(entry.emoji, style: TextStyle(fontSize: 20.sp)),
        ),
        SizedBox(height: 4.h),
        Text(
          DateFormat('HH:mm').format(entry.date),
          style: AppTextStyles.body.copyWith(
            fontSize: 10.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
