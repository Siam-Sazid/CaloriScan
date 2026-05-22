import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../domain/entities/food_item.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onDelete;
  final ValueChanged<double> onPortionChanged;

  const FoodItemCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onPortionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ConfidenceDot(score: item.confidenceScore),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: AppTextStyles.heading3),
                      const SizedBox(height: 2),
                      Text(
                        '${item.portionSize.toStringAsFixed(0)} ${item.portionUnit}',
                        style: AppTextStyles.body2,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.calories.toStringAsFixed(0)} kcal',
                      style: AppTextStyles.calorieSmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _ActionChip(
                          label: AppStrings.editPortion,
                          icon: Icons.edit_outlined,
                          onTap: () => _showPortionEditor(context),
                        ),
                        const SizedBox(width: 8),
                        _ActionChip(
                          label: AppStrings.deleteItem,
                          icon: Icons.close,
                          color: AppColors.error,
                          onTap: onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MacroPill(
                  label: 'P',
                  value: item.nutrition.protein,
                  color: AppColors.proteinColor,
                ),
                _MacroPill(
                  label: 'C',
                  value: item.nutrition.carbohydrates,
                  color: AppColors.carbsColor,
                ),
                _MacroPill(
                  label: 'F',
                  value: item.nutrition.fat,
                  color: AppColors.fatColor,
                ),
                _MacroPill(
                  label: 'Fi',
                  value: item.nutrition.fiber,
                  color: AppColors.fiberColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPortionEditor(BuildContext context) {
    final controller = TextEditingController(
      text: item.portionSize.toStringAsFixed(0),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.editPortion, style: AppTextStyles.heading3),
            const SizedBox(height: 4),
            Text(item.name, style: AppTextStyles.body2),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}'))
              ],
              decoration: InputDecoration(
                labelText: '${AppStrings.servingSize} (${item.portionUnit})',
                labelStyle: AppTextStyles.body2,
              ),
              style: AppTextStyles.body1,
              autofocus: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final value = double.tryParse(controller.text);
                  if (value != null && value > 0) {
                    onPortionChanged(value);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text(AppStrings.confirm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfidenceDot extends StatelessWidget {
  final double score;
  const _ConfidenceDot({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score > 0.9
        ? AppColors.success
        : score > 0.7
            ? AppColors.warning
            : AppColors.error;
    return Tooltip(
      message: 'Confidence: ${(score * 100).toStringAsFixed(0)}%',
      child: Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.only(top: 5),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MacroPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label,
              style: AppTextStyles.chip.copyWith(color: color, fontSize: 11)),
          Text(
            '${value.toStringAsFixed(1)}g',
            style:
                AppTextStyles.chip.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: AppTextStyles.chip.copyWith(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
