import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';

class ApiService {
  final String baseUrl = 'https://mocki.io/v1/4b1d0df4-3f52-42b2-81b4-c2f70b0c2392'; // contoh mock API

  Future<List<Recipe>> fetchRecipes() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Recipe.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data resep');
    }
  }
}
