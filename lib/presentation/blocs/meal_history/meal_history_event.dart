import 'package:equatable/equatable.dart';
import '../../../domain/entities/meal_log.dart';

abstract class MealHistoryEvent extends Equatable {
  const MealHistoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadMealHistoryEvent extends MealHistoryEvent {
  const LoadMealHistoryEvent();
}

class SaveMealEvent extends MealHistoryEvent {
  final MealLog mealLog;
  const SaveMealEvent({required this.mealLog});

  @override
  List<Object?> get props => [mealLog];
}

class DeleteMealEvent extends MealHistoryEvent {
  final String mealId;
  const DeleteMealEvent({required this.mealId});

  @override
  List<Object?> get props => [mealId];
}
