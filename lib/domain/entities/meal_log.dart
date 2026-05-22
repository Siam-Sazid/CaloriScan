import 'package:equatable/equatable.dart';
import 'food_item.dart';
import 'nutrition_info.dart';

class MealLog extends Equatable {
  final String id;
  final List<FoodItem> foodItems;
  final DateTime timestamp;
  final String? imagePath;
  final double totalCalories;
  final NutritionInfo totalNutrition;

  const MealLog({
    required this.id,
    required this.foodItems,
    required this.timestamp,
    this.imagePath,
    required this.totalCalories,
    required this.totalNutrition,
  });

  factory MealLog.fromFoodItems({
    required String id,
    required List<FoodItem> foodItems,
    String? imagePath,
  }) {
    final totalCalories =
        foodItems.fold<double>(0, (sum, item) => sum + item.calories);

    final totalNutrition = foodItems.fold<NutritionInfo>(
      const NutritionInfo(protein: 0, carbohydrates: 0, fat: 0),
      (acc, item) => NutritionInfo(
        protein: acc.protein + item.nutrition.protein,
        carbohydrates: acc.carbohydrates + item.nutrition.carbohydrates,
        fat: acc.fat + item.nutrition.fat,
        fiber: acc.fiber + item.nutrition.fiber,
        sugar: acc.sugar + item.nutrition.sugar,
        sodium: acc.sodium + item.nutrition.sodium,
      ),
    );

    return MealLog(
      id: id,
      foodItems: foodItems,
      timestamp: DateTime.now(),
      imagePath: imagePath,
      totalCalories: totalCalories,
      totalNutrition: totalNutrition,
    );
  }

  @override
  List<Object?> get props =>
      [id, foodItems, timestamp, imagePath, totalCalories, totalNutrition];
}
