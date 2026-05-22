import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../domain/entities/meal_log.dart';
import '../../injection_container.dart';
import '../blocs/food_analysis/food_analysis_bloc.dart';
import '../blocs/food_analysis/food_analysis_event.dart';
import '../blocs/food_analysis/food_analysis_state.dart';
import '../blocs/meal_history/meal_history_bloc.dart';
import '../blocs/meal_history/meal_history_event.dart';
import '../blocs/meal_history/meal_history_state.dart';
import '../widgets/calory_ring.dart';
import '../widgets/food_item_card.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/nutrition_bar.dart';

class ResultPage extends StatelessWidget {
  final File imageFile;

  const ResultPage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MealHistoryBloc>(),
      child: _ResultView(imageFile: imageFile),
    );
  }
}

class _ResultView extends StatelessWidget {
  final File imageFile;
  const _ResultView({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MealHistoryBloc, MealHistoryState>(
      listener: (context, state) {
        if (state is MealSaveSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(AppStrings.mealSaved,
                      style: AppTextStyles.body1),
                ],
              ),
            ),
          );
          Navigator.pop(context);
        }
        if (state is MealHistoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<FoodAnalysisBloc, FoodAnalysisState>(
          builder: (context, state) {
            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    _ImageAppBar(imageFile: imageFile),
                    if (state is FoodAnalysisSuccess) ...[
                      _CalorieSummarySliver(
                        totalCalories: state.totalCalories,
                        nutrition: _aggregateNutrition(state),
                      ),
                      _FoodItemsSliver(state: state),
                      _NutritionSliver(
                        totalCalories: state.totalCalories,
                        nutrition: _aggregateNutrition(state),
                      ),
                      _SaveButtonSliver(
                        state: state,
                        imageFile: imageFile,
                      ),
                    ],
                    if (state is FoodAnalysisError)
                      SliverFillRemaining(
                        child: _ErrorView(message: state.message),
                      ),
                  ],
                ),
                if (state is FoodAnalysisLoading) const LoadingOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  Map<String, double> _aggregateNutrition(FoodAnalysisSuccess state) {
    double protein = 0, carbs = 0, fat = 0, fiber = 0;
    for (final item in state.foodItems) {
      protein += item.nutrition.protein;
      carbs += item.nutrition.carbohydrates;
      fat += item.nutrition.fat;
      fiber += item.nutrition.fiber;
    }
    return {
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
    };
  }
}

class _ImageAppBar extends StatelessWidget {
  final File imageFile;
  const _ImageAppBar({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        onPressed: () {
          context.read<FoodAnalysisBloc>().add(const ResetAnalysisEvent());
          Navigator.pop(context);
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(imageFile, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.background],
                  stops: [0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalorieSummarySliver extends StatelessWidget {
  final double totalCalories;
  final Map<String, double> nutrition;

  const _CalorieSummarySliver({
    required this.totalCalories,
    required this.nutrition,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
        child: Column(
          children: [
            CaloryRing(calories: totalCalories),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _MacroStat(
                    label: AppStrings.protein,
                    value: nutrition['protein'] ?? 0,
                    color: AppColors.proteinColor),
                _MacroStat(
                    label: AppStrings.carbs,
                    value: nutrition['carbs'] ?? 0,
                    color: AppColors.carbsColor),
                _MacroStat(
                    label: AppStrings.fat,
                    value: nutrition['fat'] ?? 0,
                    color: AppColors.fatColor),
                _MacroStat(
                    label: AppStrings.fiber,
                    value: nutrition['fiber'] ?? 0,
                    color: AppColors.fiberColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroStat extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MacroStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${value.toStringAsFixed(1)}g',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _FoodItemsSliver extends StatelessWidget {
  final FoodAnalysisSuccess state;
  const _FoodItemsSliver({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<FoodAnalysisBloc>();

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(AppStrings.detectedFoods,
                        style: AppTextStyles.heading3),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${state.foodItems.length}',
                        style: AppTextStyles.chip
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              );
            }
            final item = state.foodItems[index - 1];
            return FoodItemCard(
              key: ValueKey(item.id),
              item: item,
              onDelete: () =>
                  bloc.add(RemoveFoodItemEvent(itemId: item.id)),
              onPortionChanged: (newSize) => bloc.add(
                UpdateFoodPortionEvent(
                    itemId: item.id, newPortionSize: newSize),
              ),
            );
          },
          childCount: state.foodItems.length + 1,
        ),
      ),
    );
  }
}

class _NutritionSliver extends StatelessWidget {
  final double totalCalories;
  final Map<String, double> nutrition;

  const _NutritionSliver({
    required this.totalCalories,
    required this.nutrition,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.nutritionBreakdown,
                  style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              NutritionBar(
                label: AppStrings.protein,
                value: nutrition['protein'] ?? 0,
                totalCalories: totalCalories,
                color: AppColors.proteinColor,
              ),
              NutritionBar(
                label: AppStrings.carbs,
                value: nutrition['carbs'] ?? 0,
                totalCalories: totalCalories,
                color: AppColors.carbsColor,
              ),
              NutritionBar(
                label: AppStrings.fat,
                value: nutrition['fat'] ?? 0,
                totalCalories: totalCalories,
                color: AppColors.fatColor,
              ),
              NutritionBar(
                label: AppStrings.fiber,
                value: nutrition['fiber'] ?? 0,
                totalCalories: totalCalories,
                color: AppColors.fiberColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveButtonSliver extends StatelessWidget {
  final FoodAnalysisSuccess state;
  final File imageFile;

  const _SaveButtonSliver({required this.state, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        child: BlocBuilder<MealHistoryBloc, MealHistoryState>(
          builder: (context, historyState) {
            final isSaving = historyState is MealHistoryLoading;
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSaving || state.foodItems.isEmpty
                    ? null
                    : () {
                        final mealLog = MealLog.fromFoodItems(
                          id: const Uuid().v4(),
                          foodItems: state.foodItems,
                          imagePath: imageFile.path,
                        );
                        context
                            .read<MealHistoryBloc>()
                            .add(SaveMealEvent(mealLog: mealLog));
                      },
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.background,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(
                    isSaving ? 'Saving...' : AppStrings.saveMeal),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(message,
                style: AppTextStyles.body1, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppStrings.retake),
            ),
          ],
        ),
      ),
    );
  }
}
