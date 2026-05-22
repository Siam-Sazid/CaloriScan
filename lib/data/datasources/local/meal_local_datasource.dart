import 'dart:convert';
import 'package:hive/hive.dart';
import '../../models/meal_log_model.dart';

abstract class MealLocalDataSource {
  Future<List<MealLogModel>> getMealHistory();
  Future<void> saveMeal(MealLogModel meal);
  Future<void> deleteMeal(String mealId);
}

class MealLocalDataSourceImpl implements MealLocalDataSource {
  static const String _boxName = 'meal_logs';

  Box<String> get _box => Hive.box<String>(_boxName);

  @override
  Future<List<MealLogModel>> getMealHistory() async {
    final entries = _box.values
        .map((jsonStr) =>
            MealLogModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>))
        .toList();

    // Sort descending by timestamp — O(n log n)
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  @override
  Future<void> saveMeal(MealLogModel meal) async {
    await _box.put(meal.id, jsonEncode(meal.toJson()));
  }

  @override
  Future<void> deleteMeal(String mealId) async {
    await _box.delete(mealId);
  }
}
