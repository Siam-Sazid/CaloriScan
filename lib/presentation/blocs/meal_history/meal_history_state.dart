import 'package:equatable/equatable.dart';
import '../../../domain/entities/meal_log.dart';

abstract class MealHistoryState extends Equatable {
  const MealHistoryState();
  @override
  List<Object?> get props => [];
}

class MealHistoryInitial extends MealHistoryState {
  const MealHistoryInitial();
}

class MealHistoryLoading extends MealHistoryState {
  const MealHistoryLoading();
}

class MealHistoryLoaded extends MealHistoryState {
  final List<MealLog> meals;
  const MealHistoryLoaded({required this.meals});

  @override
  List<Object?> get props => [meals];
}

class MealSaveSuccess extends MealHistoryState {
  final List<MealLog> meals;
  const MealSaveSuccess({required this.meals});

  @override
  List<Object?> get props => [meals];
}

class MealHistoryError extends MealHistoryState {
  final String message;
  const MealHistoryError({required this.message});

  @override
  List<Object?> get props => [message];
}
