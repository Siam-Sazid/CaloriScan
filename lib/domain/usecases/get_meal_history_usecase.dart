import 'package:dartz/dartz.dart';
import '../entities/meal_log.dart';
import '../repositories/food_repository.dart';
import '../../core/errors/failures.dart';
import 'usecase.dart';

class GetMealHistoryUseCase extends UseCase<List<MealLog>, NoParams> {
  final FoodRepository _repository;

  GetMealHistoryUseCase({required FoodRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<MealLog>>> call(NoParams params) =>
      _repository.getMealHistory();
}
