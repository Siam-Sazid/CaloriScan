import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/meal_log.dart';
import '../../../domain/usecases/delete_meal_usecase.dart';
import '../../../domain/usecases/get_meal_history_usecase.dart';
import '../../../domain/usecases/save_meal_usecase.dart';
import '../../../domain/usecases/usecase.dart';
import 'meal_history_event.dart';
import 'meal_history_state.dart';

class MealHistoryBloc extends Bloc<MealHistoryEvent, MealHistoryState> {
  final GetMealHistoryUseCase _getMealHistoryUseCase;
  final SaveMealUseCase _saveMealUseCase;
  final DeleteMealUseCase _deleteMealUseCase;

  // In-memory list mirrors the local store for O(1) UI updates
  final List<MealLog> _meals = [];

  MealHistoryBloc({
    required GetMealHistoryUseCase getMealHistoryUseCase,
    required SaveMealUseCase saveMealUseCase,
    required DeleteMealUseCase deleteMealUseCase,
  })  : _getMealHistoryUseCase = getMealHistoryUseCase,
        _saveMealUseCase = saveMealUseCase,
        _deleteMealUseCase = deleteMealUseCase,
        super(const MealHistoryInitial()) {
    on<LoadMealHistoryEvent>(_onLoadMealHistory);
    on<SaveMealEvent>(_onSaveMeal);
    on<DeleteMealEvent>(_onDeleteMeal);
  }

  Future<void> _onLoadMealHistory(
    LoadMealHistoryEvent event,
    Emitter<MealHistoryState> emit,
  ) async {
    emit(const MealHistoryLoading());

    final result = await _getMealHistoryUseCase(const NoParams());

    result.fold(
      (failure) => emit(MealHistoryError(message: failure.message)),
      (meals) {
        _meals
          ..clear()
          ..addAll(meals);
        emit(MealHistoryLoaded(meals: List.unmodifiable(_meals)));
      },
    );
  }

  Future<void> _onSaveMeal(
    SaveMealEvent event,
    Emitter<MealHistoryState> emit,
  ) async {
    final result =
        await _saveMealUseCase(SaveMealParams(mealLog: event.mealLog));

    result.fold(
      (failure) => emit(MealHistoryError(message: failure.message)),
      (_) {
        // Insert at head — newest first; O(n) but list is small
        _meals.insert(0, event.mealLog);
        emit(MealSaveSuccess(meals: List.unmodifiable(_meals)));
      },
    );
  }

  Future<void> _onDeleteMeal(
    DeleteMealEvent event,
    Emitter<MealHistoryState> emit,
  ) async {
    final result =
        await _deleteMealUseCase(DeleteMealParams(mealId: event.mealId));

    result.fold(
      (failure) => emit(MealHistoryError(message: failure.message)),
      (_) {
        _meals.removeWhere((m) => m.id == event.mealId);
        emit(MealHistoryLoaded(meals: List.unmodifiable(_meals)));
      },
    );
  }
}
