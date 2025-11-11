import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

// Background message handler - harus di top level
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('📨 Pesan background diterima: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
}

// Global notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Navigator key untuk routing dari notifikasi
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Notification channel untuk Android
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'rasatara_channel', // id
  'Rasatara Notifications', // nama
  description: 'Channel untuk notifikasi Rasatara',
  importance: Importance.max,
  playSound: true,
  showBadge: true,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize local notifications
  await initializeLocalNotifications();

  // Create notification channel untuk Android
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const RasataraApp());
}

// Initialize local notifications dengan setting lengkap
Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      print('🔔 Notifikasi diklik: ${response.payload}');
      
      // Handle navigation ketika notifikasi diklik
      if (response.payload != null) {
        handleNotificationClick(response.payload!);
      }
    },
  );
}

// Handle klik notifikasi
void handleNotificationClick(String payload) {
  print('Navigasi ke: $payload');
  
  if (payload == 'home') {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  } else if (payload == 'login') {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}

class RasataraApp extends StatefulWidget {
  const RasataraApp({super.key});

  @override
  State<RasataraApp> createState() => _RasataraAppState();
}

class _RasataraAppState extends State<RasataraApp> {
  @override
  void initState() {
    super.initState();
    setupFCM();
  }

  void setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission untuk notifikasi
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('✅ Permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission');
      
      // Get FCM token
      String? token = await messaging.getToken();
      print("🔑 FCM Token: $token");
      
      // TODO: Kirim token ini ke backend server Anda untuk menyimpannya
      // await sendTokenToServer(token);

    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('⚠️ User granted provisional permission');
    } else {
      print('❌ User declined or has not accepted permission');
    }

    // Handle pesan ketika app sedang terbuka (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Pesan diterima saat app terbuka!');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');

      // Tampilkan notifikasi lokal
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    // Handle ketika user membuka app dari notifikasi
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 App dibuka dari notifikasi!');
      print('Title: ${message.notification?.title}');
      print('Data: ${message.data}');

      // Navigate berdasarkan data dari notifikasi
      final page = message.data['page'];
      if (page == 'home') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (page == 'login') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });

    // Check apakah app dibuka dari notifikasi saat terminated
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      print('🚀 App dibuka dari terminated state via notifikasi');
      final page = initialMessage.data['page'];
      if (page != null) {
        // Delay sedikit untuk memastikan app sudah siap
        Future.delayed(const Duration(seconds: 1), () {
          handleNotificationClick(page);
        });
      }
    }
  }

  // Tampilkan notifikasi lokal
  void _showLocalNotification(RemoteMessage message) async {
    try {
      // Extract data untuk payload
      final String payload = message.data['page'] ?? '';

      await flutterLocalNotificationsPlugin.show(
        message.notification.hashCode,
        message.notification?.title ?? 'Rasatara',
        message.notification?.body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            styleInformation: BigTextStyleInformation(
              message.notification?.body ?? '',
            ),
          ),
        ),
        payload: payload, // Untuk handle klik notifikasi
      );
      
      print('✅ Local notification displayed');
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Rasatara',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}