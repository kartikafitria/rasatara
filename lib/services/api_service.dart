import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://dummyjson.com/recipes";

  // Ambil semua resep
  Future<List<dynamic>> getRecipes() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['recipes'];
    } else {
      throw Exception("Gagal mengambil data resep");
    }
  }

  // Ambil detail resep berdasarkan ID
  Future<Map<String, dynamic>> getRecipeDetail(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Gagal mengambil detail resep");
    }
  }
}
