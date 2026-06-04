import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/errors/exceptions.dart';
import '../../../core/utils/image_compressor.dart';
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

/// Real implementation — calls the Claude Vision API.
/// Build with: flutter run --dart-define=CLAUDE_API_KEY=my_key
class ClaudeAiDataSourceImpl implements ClaudeAiDataSource {
  static const String _apiKey = String.fromEnvironment('CLAUDE_API_KEY');
  static const String _model = 'claude-sonnet-4-6';
  static const String _endpoint = 'https://api.anthropic.com/v1/messages';

  static const String _prompt = '''
Analyze the food in this image. Return ONLY a JSON array — no markdown, no explanation.
Each element must have this exact shape:
{
  "id": "item_1",
  "name": "Steamed Rice",
  "calories": 242.0,
  "portion_size": 180.0,
  "portion_unit": "g",
  "nutrition": {
    "protein": 4.4,
    "carbohydrates": 53.2,
    "fat": 0.4,
    "fiber": 0.6,
    "sugar": 0.0,
    "sodium": 1.0
  },
  "confidence_score": 0.96
}

Rules:
- id: "item_1", "item_2", ... (unique, sequential)
- calories: total kcal for the estimated portion
- portion_size: numeric weight or volume of the portion
- portion_unit: "g" (solids), "ml" (liquids), or "piece" (whole items)
- nutrition: all values in grams; sodium in mg
- confidence_score: 0.0-1.0
- Return [] if no food is visible.
''';

  @override
  Future<List<FoodItemModel>> analyzeFoodImage(File imageFile) async {
    try {
      final base64Image = await ImageCompressor.toBase64(imageFile);
      final mime = ImageCompressor.mimeType(imageFile);

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'content-type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 4096,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image',
                  'source': {
                    'type': 'base64',
                    'media_type': mime,
                    'data': base64Image,
                  },
                },
                {
                  'type': 'text',
                  'text': _prompt,
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Claude API error ${response.statusCode}: ${response.body}',
        );
      }

      return _parseResponse(response.body);
    } on ServerException {
      rethrow;
    } on ImageProcessingException {
      rethrow;
    } catch (e) {
      throw NetworkException(message: 'Claude API request failed: $e');
    }
  }

  List<FoodItemModel> _parseResponse(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
      final content = decoded['content'] as List<dynamic>;
      final text = (content.first as Map<String, dynamic>)['text'] as String;
      return _parseFoodJson(text);
    } catch (e) {
      throw ServerException(message: 'Failed to parse Claude response: $e');
    }
  }

  List<FoodItemModel> _parseFoodJson(String text) {
    var clean = text.trim();
    // Strip markdown code fences Claude may add despite instructions
    if (clean.startsWith('```')) {
      clean = clean.replaceFirst(RegExp(r'^```[a-z]*\n?'), '');
      clean = clean.replaceFirst(RegExp(r'```\s*$'), '');
      clean = clean.trim();
    }
    final list = jsonDecode(clean) as List<dynamic>;
    return list
        .map((e) => FoodItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
