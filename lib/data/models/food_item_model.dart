import '../../domain/entities/food_item.dart';
import 'nutrition_info_model.dart';

class FoodItemModel extends FoodItem {
  const FoodItemModel({
    required super.id,
    required super.name,
    required super.calories,
    required super.portionSize,
    required super.portionUnit,
    required super.nutrition,
    super.confidenceScore,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) => FoodItemModel(
        id: json['id'] as String,
        name: json['name'] as String,
        calories: (json['calories'] as num).toDouble(),
        portionSize: (json['portion_size'] as num).toDouble(),
        portionUnit: json['portion_unit'] as String,
        nutrition: NutritionInfoModel.fromJson(
          json['nutrition'] as Map<String, dynamic>,
        ),
        confidenceScore:
            (json['confidence_score'] as num? ?? 1.0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'calories': calories,
        'portion_size': portionSize,
        'portion_unit': portionUnit,
        'nutrition': NutritionInfoModel.fromEntity(nutrition).toJson(),
        'confidence_score': confidenceScore,
      };

  factory FoodItemModel.fromEntity(FoodItem entity) => FoodItemModel(
        id: entity.id,
        name: entity.name,
        calories: entity.calories,
        portionSize: entity.portionSize,
        portionUnit: entity.portionUnit,
        nutrition: entity.nutrition,
        confidenceScore: entity.confidenceScore,
      );
}
