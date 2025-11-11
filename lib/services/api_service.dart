import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();

  // ✅ Ambil semua resep
  Future<List<dynamic>> getRecipes() async {
    final response = await _dio.get(
      'https://www.themealdb.com/api/json/v1/1/search.php?s=',
    );

    final data = response.data['meals'];
    if (data == null) return [];

    return data.map((meal) {
      return {
        'id': meal['idMeal'],
        'name': meal['strMeal'],
        'image': meal['strMealThumb'],
        'cookTimeMinutes': 20, // Placeholder karena API tidak menyediakan waktu masak
      };
    }).toList();
  }

  // ✅ Ambil resep berdasarkan kategori (misal: Snack, Dessert, dll)
  Future<List<dynamic>> getRecipesByCategory(String category) async {
    try {
      final response = await _dio.get(
        'https://www.themealdb.com/api/json/v1/1/filter.php?c=$category',
      );
      final data = response.data['meals'];
      if (data == null) return [];

      return data.map((meal) {
        return {
          'id': meal['idMeal'],
          'name': meal['strMeal'],
          'image': meal['strMealThumb'],
          'cookTimeMinutes': 15, // Placeholder waktu
        };
      }).toList();
    } catch (e) {
      print('❌ Error getRecipesByCategory: $e');
      return [];
    }
  }

  // ✅ Ambil detail resep berdasarkan ID
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

      // Ambil daftar bahan dan takaran
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

      // Pisahkan langkah instruksi berdasarkan baris
      final instructionsRaw = meal['strInstructions'] ?? '';
      final instructions = instructionsRaw
          .toString()
          .split(RegExp(r'\r?\n'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      return {
        'id': meal['idMeal'],
        'name': meal['strMeal'],
        'image': meal['strMealThumb'],
        'cookTimeMinutes': 20,
        'ingredients': ingredients,
        'instructions': instructions,
      };
    } catch (e) {
      print('❌ Error getRecipeDetail: $e');
      rethrow;
    }
  }
}
