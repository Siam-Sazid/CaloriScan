import 'package:equatable/equatable.dart';
import 'nutrition_info.dart';

class FoodItem extends Equatable {
  final String id;
  final String name;
  final double calories;
  final double portionSize;
  final String portionUnit;
  final NutritionInfo nutrition;
  final double confidenceScore;

  const FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.portionSize,
    required this.portionUnit,
    required this.nutrition,
    this.confidenceScore = 1.0,
  });

  FoodItem copyWith({
    String? id,
    String? name,
    double? calories,
    double? portionSize,
    String? portionUnit,
    NutritionInfo? nutrition,
    double? confidenceScore,
  }) =>
      FoodItem(
        id: id ?? this.id,
        name: name ?? this.name,
        calories: calories ?? this.calories,
        portionSize: portionSize ?? this.portionSize,
        portionUnit: portionUnit ?? this.portionUnit,
        nutrition: nutrition ?? this.nutrition,
        confidenceScore: confidenceScore ?? this.confidenceScore,
      );

  @override
  List<Object?> get props =>
      [id, name, calories, portionSize, portionUnit, nutrition, confidenceScore];
}
