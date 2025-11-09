import 'package:flutter/material.dart';
import '../models/recipe_model.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(recipe.imageUrl, fit: BoxFit.cover),
            const SizedBox(height: 20),
            Text(
              recipe.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(recipe.description),
            const Divider(height: 30, thickness: 2),
            const Text(
              'Bahan-bahan:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ...recipe.ingredients.map((i) => Text('• $i')).toList(),
            const Divider(height: 30, thickness: 2),
            const Text(
              'Langkah-langkah:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ...recipe.steps.asMap().entries.map(
              (e) => Text('${e.key + 1}. ${e.value}'),
            ),
          ],
        ),
      ),
    );
  }
}
