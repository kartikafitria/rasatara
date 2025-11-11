import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String id; // ✅ ubah ke String agar cocok dengan API
  const RecipeDetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final ApiService apiService = ApiService();
  late Future<Map<String, dynamic>> _recipeDetail;

  @override
  void initState() {
    super.initState();
    _recipeDetail = apiService.getRecipeDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Resep"),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _recipeDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Data tidak ditemukan."));
          } else {
            final recipe = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🖼️ Gambar resep
                  if (recipe['image'] != null && recipe['image'].toString().isNotEmpty)
                    Image.network(
                      recipe['image'],
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🧾 Nama resep
                        Text(
                          recipe['name'] ?? 'Nama Resep Tidak Ditemukan',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.timer, color: Colors.deepOrange),
                            const SizedBox(width: 6),
                            Text("${recipe['cookTimeMinutes']} menit"),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // 🍅 Daftar bahan
                        const Text(
                          "Bahan-bahan",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        ...List.generate(
                          (recipe['ingredients'] as List).length,
                          (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text("• ${recipe['ingredients'][i]}"),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 🔪 Langkah memasak
                        const Text(
                          "Langkah-langkah",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        ...List.generate(
                          (recipe['instructions'] as List).length,
                          (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text("${i + 1}. ${recipe['instructions'][i]}"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
