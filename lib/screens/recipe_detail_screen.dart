import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int id;
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
                        Text(
                          recipe['name'],
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
                        const SizedBox(height: 16),
                        const Text(
                          "Bahan-bahan",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...List.generate(
                          recipe['ingredients'].length,
                          (i) => Text("• ${recipe['ingredients'][i]}"),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Langkah-langkah",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...List.generate(
                          recipe['instructions'].length,
                          (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
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
