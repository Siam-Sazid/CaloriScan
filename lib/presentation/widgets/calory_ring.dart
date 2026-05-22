import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class CaloryRing extends StatelessWidget {
  final double calories;
  final double dailyGoal;
  final double radius;

  const CaloryRing({
    super.key,
    required this.calories,
    this.dailyGoal = 2000,
    this.radius = 90,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (calories / dailyGoal).clamp(0.0, 1.0);
    final Color ringColor = percent < 0.7
        ? AppColors.primary
        : percent < 0.9
            ? AppColors.warning
            : AppColors.error;

    return CircularPercentIndicator(
      radius: radius,
      lineWidth: 12,
      percent: percent,
      animation: true,
      animationDuration: 900,
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: AppColors.divider,
      progressColor: ringColor,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            calories.toStringAsFixed(0),
            style: AppTextStyles.calorieLarge.copyWith(color: ringColor),
          ),
          Text('kcal', style: AppTextStyles.label),
        ],
      ),
    );
  }
}
