import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'rasatara_channel',
    'Rasatara Notifications',
    description: 'Channel untuk notifikasi aplikasi Rasatara',
    importance: Importance.max,
    playSound: true,
    showBadge: true,
  );

  // Initialize notification service
  Future<void> initialize() async {
    // Setup Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<bool> requestPermission() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('🔔 Notification permission: ${settings.authorizationStatus}');
    
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<String?> getFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      print(' Subscribed to topic: $topic');
    } catch (e) {
      print(' Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      print(' Unsubscribed from topic: $topic');
    } catch (e) {
      print(' Error unsubscribing from topic: $e');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _localNotifications.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            styleInformation: BigTextStyleInformation(body),
          ),
        ),
        payload: payload,
      );
      print(' Local notification shown');
    } catch (e) {
      print(' Error showing notification: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notification tapped with payload: ${response.payload}');
    
 
  }

  void setupFCMListeners({
    required Function(RemoteMessage) onMessageReceived,
    required Function(RemoteMessage) onMessageOpened,
  }) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Message received in foreground');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      
      onMessageReceived(message);
      
      if (message.notification != null) {
        showNotification(
          id: message.notification.hashCode,
          title: message.notification?.title ?? 'Rasatara',
          body: message.notification?.body ?? '',
          payload: message.data['page'],
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(' Message opened from background/terminated');
      onMessageOpened(message);
    });
  }

  Future<RemoteMessage?> getInitialMessage() async {
    return await FirebaseMessaging.instance.getInitialMessage();
  }
}