import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/meal_log.dart';
import '../repositories/food_repository.dart';
import '../../core/errors/failures.dart';
import 'usecase.dart';

class SaveMealUseCase extends UseCase<void, SaveMealParams> {
  final FoodRepository _repository;

  SaveMealUseCase({required FoodRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, void>> call(SaveMealParams params) =>
      _repository.saveMeal(params.mealLog);
}

class SaveMealParams extends Equatable {
  final MealLog mealLog;
  const SaveMealParams({required this.mealLog});

  @override
  List<Object?> get props => [mealLog];
}
