import 'dart:io';
import '../../models/food_item_model.dart';

// Abstract contract — implementation added once API key is available
abstract class ClaudeAiDataSource {
  Future<List<FoodItemModel>> analyzeFoodImage(File imageFile);
}

// Stub returns realistic mock data so UI can be fully developed and tested
// Replace with ClaudeAiDataSourceImpl once API key is ready
class ClaudeAiDataSourceStub implements ClaudeAiDataSource {
  @override
  Future<List<FoodItemModel>> analyzeFoodImage(File imageFile) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate API latency
    return _mockFoodItems();
  }

  List<FoodItemModel> _mockFoodItems() => [
        FoodItemModel.fromJson({
          'id': 'mock_001',
          'name': 'Steamed Rice',
          'calories': 242.0,
          'portion_size': 180.0,
          'portion_unit': 'g',
          'nutrition': {
            'protein': 4.4,
            'carbohydrates': 53.2,
            'fat': 0.4,
            'fiber': 0.6,
            'sugar': 0.0,
            'sodium': 1.0,
          },
          'confidence_score': 0.96,
        }),
        FoodItemModel.fromJson({
          'id': 'mock_002',
          'name': 'Grilled Chicken Breast',
          'calories': 165.0,
          'portion_size': 100.0,
          'portion_unit': 'g',
          'nutrition': {
            'protein': 31.0,
            'carbohydrates': 0.0,
            'fat': 3.6,
            'fiber': 0.0,
            'sugar': 0.0,
            'sodium': 74.0,
          },
          'confidence_score': 0.92,
        }),
        FoodItemModel.fromJson({
          'id': 'mock_003',
          'name': 'Mixed Green Salad',
          'calories': 35.0,
          'portion_size': 85.0,
          'portion_unit': 'g',
          'nutrition': {
            'protein': 2.5,
            'carbohydrates': 6.5,
            'fat': 0.4,
            'fiber': 2.1,
            'sugar': 2.8,
            'sodium': 28.0,
          },
          'confidence_score': 0.88,
        }),
      ];
}
