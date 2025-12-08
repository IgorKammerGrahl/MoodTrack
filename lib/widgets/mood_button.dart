import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum MoodButtonStyle { primary, secondary }

class MoodButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final MoodButtonStyle style;
  final bool isLoading;

  const MoodButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.style = MoodButtonStyle.primary,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPrimary = style == MoodButtonStyle.primary;

    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.primary : Colors.transparent,
          foregroundColor: isPrimary ? Colors.white : AppColors.primary,
          elevation: 0,
          side: isPrimary
              ? null
              : BorderSide(color: AppColors.primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isPrimary ? Colors.white : AppColors.primary,
                  ),
                ),
              )
            : Text(
                label,
                style: AppTextStyles.button.copyWith(
                  color: isPrimary ? Colors.white : AppColors.primary,
                ),
              ),
      ),
    );
  }
}
