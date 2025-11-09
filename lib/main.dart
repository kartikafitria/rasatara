import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RasataraApp());
}

class RasataraApp extends StatefulWidget {
  const RasataraApp({super.key});

  @override
  State<RasataraApp> createState() => _RasataraAppState();
}

class _RasataraAppState extends State<RasataraApp> {
  Widget _defaultScreen = const SplashScreen();

  @override
  void initState() {
    super.initState();
    _setupInitialScreen();
  }

  Future<void> _setupInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    final user = FirebaseAuth.instance.currentUser;

    await Future.delayed(const Duration(seconds: 2)); // splash delay

    if (!seenOnboarding) {
      setState(() {
        _defaultScreen = const OnboardingScreen();
      });
    } else if (user == null) {
      setState(() {
        _defaultScreen = const LoginScreen();
      });
    } else {
      setState(() {
        _defaultScreen = const HomeScreen();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rasatara',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: _defaultScreen,
    );
  }
}
