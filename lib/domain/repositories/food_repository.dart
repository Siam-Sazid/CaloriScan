import 'dart:io';
import 'package:dartz/dartz.dart';
import '../entities/food_item.dart';
import '../entities/meal_log.dart';
import '../../core/errors/failures.dart';

abstract class FoodRepository {
  Future<Either<Failure, List<FoodItem>>> analyzeFoodImage(File imageFile);
  Future<Either<Failure, List<MealLog>>> getMealHistory();
  Future<Either<Failure, void>> saveMeal(MealLog mealLog);
  Future<Either<Failure, void>> deleteMeal(String mealId);
}
