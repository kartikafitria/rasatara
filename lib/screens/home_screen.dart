import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'login_screen.dart';
import 'recipe_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _dailyTip;

  @override
  void initState() {
    super.initState();
    _initializeFCM();
    _generateRandomTip();
  }

  Future<void> _initializeFCM() async {
    try {
      await FirebaseMessaging.instance.requestPermission();
      final token = await FirebaseMessaging.instance.getToken();
      print(' FCM aktif (token disembunyikan): $token');
    } catch (e) {
      print(' Gagal inisialisasi FCM: $e');
    }
  }

  void _generateRandomTip() {
    final tips = [
      "Gunakan minyak zaitun untuk menumis agar lebih sehat 🌿",
      "Tambahkan sedikit gula ke saus tomat untuk rasa seimbang 🍅",
      "Gunakan air jeruk nipis untuk menghilangkan bau amis ikan 🐟",
      "Cuci beras dengan air dingin agar nasi lebih pulen 🍚",
      "Simpan rempah di tempat gelap agar aroma tidak cepat hilang 🌶️",
    ];
    _dailyTip = tips[Random().nextInt(tips.length)];
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout gagal: $e')),
      );
    }
  }

  void _openCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeListScreen(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Beranda Rasatara"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null)
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage:
                        user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                    child: user.photoURL == null
                        ? const Icon(Icons.person, size: 35)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Halo, ${user.displayName?.split(' ')[0] ?? 'Chef'}! 👋",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                "Selamat datang di Rasatara! 🍲\nTemukan resep lezat setiap hari!",
                style: TextStyle(fontSize: 16, color: Colors.deepOrange),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Kategori Populer 🍛",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _CategoryCard(
                    icon: Icons.lunch_dining,
                    label: "Beef",
                    onTap: () => _openCategory("Beef"),
                  ),
                  _CategoryCard(
                    icon: Icons.breakfast_dining,
                    label: "Breakfast",
                    onTap: () => _openCategory("Breakfast"),
                  ),
                  _CategoryCard(
                    icon: Icons.cake,
                    label: "Dessert",
                    onTap: () => _openCategory("Dessert"),
                  ),
                  _CategoryCard(
                    icon: Icons.ramen_dining,
                    label: "Seafood",
                    onTap: () => _openCategory("Seafood"),
                  ),
                  _CategoryCard(
                    icon: Icons.eco,
                    label: "Vegetarian",
                    onTap: () => _openCategory("Vegetarian"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.restaurant_menu),
                label: const Text("Lihat Semua Resep"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RecipeListScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 35),

            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_dailyTip)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.deepOrange, size: 30),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
