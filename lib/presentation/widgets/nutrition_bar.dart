import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class NutritionBar extends StatelessWidget {
  final String label;
  final double value;
  final double totalCalories;
  final Color color;

  const NutritionBar({
    super.key,
    required this.label,
    required this.value,
    required this.totalCalories,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Each gram of protein/carbs = 4 kcal, fat = 9 kcal
    final kcalContrib = label == 'Fat' ? value * 9 : value * 4;
    final percent =
        totalCalories > 0 ? (kcalContrib / totalCalories).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.body2),
              Text(
                '${value.toStringAsFixed(1)}g',
                style: AppTextStyles.body2.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
