import '../../domain/entities/meal_log.dart';
import 'food_item_model.dart';
import 'nutrition_info_model.dart';

class MealLogModel extends MealLog {
  const MealLogModel({
    required super.id,
    required super.foodItems,
    required super.timestamp,
    super.imagePath,
    required super.totalCalories,
    required super.totalNutrition,
  });

  factory MealLogModel.fromJson(Map<String, dynamic> json) => MealLogModel(
        id: json['id'] as String,
        foodItems: (json['food_items'] as List)
            .map((e) => FoodItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        timestamp: DateTime.parse(json['timestamp'] as String),
        imagePath: json['image_path'] as String?,
        totalCalories: (json['total_calories'] as num).toDouble(),
        totalNutrition: NutritionInfoModel.fromJson(
          json['total_nutrition'] as Map<String, dynamic>,
        ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'food_items': foodItems
            .map((e) => FoodItemModel.fromEntity(e).toJson())
            .toList(),
        'timestamp': timestamp.toIso8601String(),
        'image_path': imagePath,
        'total_calories': totalCalories,
        'total_nutrition':
            NutritionInfoModel.fromEntity(totalNutrition).toJson(),
      };

  factory MealLogModel.fromEntity(MealLog entity) => MealLogModel(
        id: entity.id,
        foodItems: entity.foodItems,
        timestamp: entity.timestamp,
        imagePath: entity.imagePath,
        totalCalories: entity.totalCalories,
        totalNutrition: entity.totalNutrition,
      );
}
