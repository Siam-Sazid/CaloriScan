import '../../domain/entities/nutrition_info.dart';

class NutritionInfoModel extends NutritionInfo {
  const NutritionInfoModel({
    required super.protein,
    required super.carbohydrates,
    required super.fat,
    super.fiber,
    super.sugar,
    super.sodium,
  });

  factory NutritionInfoModel.fromJson(Map<String, dynamic> json) =>
      NutritionInfoModel(
        protein: (json['protein'] as num).toDouble(),
        carbohydrates: (json['carbohydrates'] as num).toDouble(),
        fat: (json['fat'] as num).toDouble(),
        fiber: (json['fiber'] as num? ?? 0).toDouble(),
        sugar: (json['sugar'] as num? ?? 0).toDouble(),
        sodium: (json['sodium'] as num? ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'protein': protein,
        'carbohydrates': carbohydrates,
        'fat': fat,
        'fiber': fiber,
        'sugar': sugar,
        'sodium': sodium,
      };

  factory NutritionInfoModel.fromEntity(NutritionInfo entity) =>
      NutritionInfoModel(
        protein: entity.protein,
        carbohydrates: entity.carbohydrates,
        fat: entity.fat,
        fiber: entity.fiber,
        sugar: entity.sugar,
        sodium: entity.sodium,
      );
}
