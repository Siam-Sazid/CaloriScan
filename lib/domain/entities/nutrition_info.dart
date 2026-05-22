import 'package:equatable/equatable.dart';

class NutritionInfo extends Equatable {
  final double protein;
  final double carbohydrates;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;

  const NutritionInfo({
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
  });

  // Scales all macro values by a ratio — used when portion size changes
  NutritionInfo scale(double ratio) => NutritionInfo(
        protein: protein * ratio,
        carbohydrates: carbohydrates * ratio,
        fat: fat * ratio,
        fiber: fiber * ratio,
        sugar: sugar * ratio,
        sodium: sodium * ratio,
      );

  NutritionInfo copyWith({
    double? protein,
    double? carbohydrates,
    double? fat,
    double? fiber,
    double? sugar,
    double? sodium,
  }) =>
      NutritionInfo(
        protein: protein ?? this.protein,
        carbohydrates: carbohydrates ?? this.carbohydrates,
        fat: fat ?? this.fat,
        fiber: fiber ?? this.fiber,
        sugar: sugar ?? this.sugar,
        sodium: sodium ?? this.sodium,
      );

  @override
  List<Object?> get props =>
      [protein, carbohydrates, fat, fiber, sugar, sodium];
}
