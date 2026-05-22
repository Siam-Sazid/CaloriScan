import 'dart:collection';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/food_item.dart';
import '../../../domain/usecases/analyze_food_image_usecase.dart';
import 'food_analysis_event.dart';
import 'food_analysis_state.dart';

class FoodAnalysisBloc extends Bloc<FoodAnalysisEvent, FoodAnalysisState> {
  final AnalyzeFoodImageUseCase _analyzeFoodImageUseCase;

  // LinkedHashMap preserves insertion order with O(1) access and update
  final LinkedHashMap<String, FoodItem> _itemsCache = LinkedHashMap();

  FoodAnalysisBloc({
    required AnalyzeFoodImageUseCase analyzeFoodImageUseCase,
  })  : _analyzeFoodImageUseCase = analyzeFoodImageUseCase,
        super(const FoodAnalysisInitial()) {
    on<AnalyzeFoodImageEvent>(_onAnalyzeFoodImage);
    on<UpdateFoodPortionEvent>(_onUpdateFoodPortion);
    on<RemoveFoodItemEvent>(_onRemoveFoodItem);
    on<ResetAnalysisEvent>(_onResetAnalysis);
  }

  Future<void> _onAnalyzeFoodImage(
    AnalyzeFoodImageEvent event,
    Emitter<FoodAnalysisState> emit,
  ) async {
    emit(const FoodAnalysisLoading());
    _itemsCache.clear();

    final result = await _analyzeFoodImageUseCase(
      AnalyzeFoodParams(imageFile: event.imageFile),
    );

    result.fold(
      (failure) => emit(FoodAnalysisError(message: failure.message)),
      (foodItems) {
        for (final item in foodItems) {
          _itemsCache[item.id] = item;
        }
        emit(FoodAnalysisSuccess(
          foodItems: List.unmodifiable(_itemsCache.values),
          imageFile: event.imageFile,
          totalCalories: _sumCalories(),
        ));
      },
    );
  }

  void _onUpdateFoodPortion(
    UpdateFoodPortionEvent event,
    Emitter<FoodAnalysisState> emit,
  ) {
    final original = _itemsCache[event.itemId];
    if (original == null || state is! FoodAnalysisSuccess) return;

    final ratio = event.newPortionSize / original.portionSize;
    _itemsCache[event.itemId] = original.copyWith(
      portionSize: event.newPortionSize,
      calories: original.calories * ratio,
      nutrition: original.nutrition.scale(ratio),
    );

    emit((state as FoodAnalysisSuccess).copyWith(
      foodItems: List.unmodifiable(_itemsCache.values),
      totalCalories: _sumCalories(),
    ));
  }

  void _onRemoveFoodItem(
    RemoveFoodItemEvent event,
    Emitter<FoodAnalysisState> emit,
  ) {
    _itemsCache.remove(event.itemId);
    if (state is! FoodAnalysisSuccess) return;

    emit((state as FoodAnalysisSuccess).copyWith(
      foodItems: List.unmodifiable(_itemsCache.values),
      totalCalories: _sumCalories(),
    ));
  }

  void _onResetAnalysis(
    ResetAnalysisEvent event,
    Emitter<FoodAnalysisState> emit,
  ) {
    _itemsCache.clear();
    emit(const FoodAnalysisInitial());
  }

  double _sumCalories() =>
      _itemsCache.values.fold(0, (sum, item) => sum + item.calories);
}
