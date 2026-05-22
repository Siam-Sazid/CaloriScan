import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../repositories/food_repository.dart';
import '../../core/errors/failures.dart';
import 'usecase.dart';

class DeleteMealUseCase extends UseCase<void, DeleteMealParams> {
  final FoodRepository _repository;

  DeleteMealUseCase({required FoodRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, void>> call(DeleteMealParams params) =>
      _repository.deleteMeal(params.mealId);
}

class DeleteMealParams extends Equatable {
  final String mealId;
  const DeleteMealParams({required this.mealId});

  @override
  List<Object?> get props => [mealId];
}
