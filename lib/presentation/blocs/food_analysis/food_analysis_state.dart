import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/food_item.dart';

abstract class FoodAnalysisState extends Equatable {
  const FoodAnalysisState();
  @override
  List<Object?> get props => [];
}

class FoodAnalysisInitial extends FoodAnalysisState {
  const FoodAnalysisInitial();
}

class FoodAnalysisLoading extends FoodAnalysisState {
  const FoodAnalysisLoading();
}

class FoodAnalysisSuccess extends FoodAnalysisState {
  final List<FoodItem> foodItems;
  final File imageFile;
  final double totalCalories;

  const FoodAnalysisSuccess({
    required this.foodItems,
    required this.imageFile,
    required this.totalCalories,
  });

  FoodAnalysisSuccess copyWith({
    List<FoodItem>? foodItems,
    File? imageFile,
    double? totalCalories,
  }) =>
      FoodAnalysisSuccess(
        foodItems: foodItems ?? this.foodItems,
        imageFile: imageFile ?? this.imageFile,
        totalCalories: totalCalories ?? this.totalCalories,
      );

  @override
  List<Object?> get props => [foodItems, imageFile.path, totalCalories];
}

class FoodAnalysisError extends FoodAnalysisState {
  final String message;
  const FoodAnalysisError({required this.message});

  @override
  List<Object?> get props => [message];
}
