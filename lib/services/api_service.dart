import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<List<dynamic>> getRecipes() async {
    try {
      final response = await _dio.get(
        'https://www.themealdb.com/api/json/v1/1/search.php?s=',
      );

      final data = response.data['meals'];
      if (data == null) return [];

      return data.map((meal) {
        return {
          'id': meal['idMeal'] ?? '',
          'name': meal['strMeal'] ?? 'Resep tanpa nama',
          'image': meal['strMealThumb'] ??
              'https://via.placeholder.com/150?text=No+Image',
          'cookTimeMinutes': 20, 
        };
      }).toList();
    } catch (e) {
      print('❌ Error getRecipes: $e');
      return [];
    }
  }

  Future<List<dynamic>> getRecipesByCategory(String category) async {
    try {
      final response = await _dio.get(
        'https://www.themealdb.com/api/json/v1/1/filter.php?c=$category',
      );
      final data = response.data['meals'];
      if (data == null) return [];

      return data.map((meal) {
        return {
          'id': meal['idMeal'] ?? '',
          'name': meal['strMeal'] ?? 'Resep tanpa nama',
          'image': meal['strMealThumb'] ??
              'https://via.placeholder.com/150?text=No+Image',
          'cookTimeMinutes': 15, 
        };
      }).toList();
    } catch (e) {
      print('❌ Error getRecipesByCategory: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getRecipeDetail(String id) async {
    try {
      final response = await _dio.get(
        'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$id',
      );

      final meals = response.data['meals'];
      if (meals == null || (meals is List && meals.isEmpty)) {
        throw Exception('Recipe not found');
      }

      final meal = meals[0];

      final List<String> ingredients = [];
      for (var i = 1; i <= 20; i++) {
        final ing = meal['strIngredient$i'];
        final measure = meal['strMeasure$i'];
        if (ing != null && ing.toString().trim().isNotEmpty) {
          final item = (measure != null && measure.toString().trim().isNotEmpty)
              ? '${measure.toString().trim()} ${ing.toString().trim()}'
              : ing.toString().trim();
          ingredients.add(item);
        }
      }

      final instructionsRaw = meal['strInstructions'] ?? '';
      final instructions = instructionsRaw
          .toString()
          .split(RegExp(r'\r?\n'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      return {
        'id': meal['idMeal'] ?? '',
        'name': meal['strMeal'] ?? 'Resep tanpa nama',
        'image': meal['strMealThumb'] ??
            'https://via.placeholder.com/150?text=No+Image',
        'cookTimeMinutes': 20,
        'ingredients': ingredients,
        'instructions': instructions,
      };
    } catch (e) {
      print(' Error getRecipeDetail: $e');
      rethrow;
    }
  }
}
