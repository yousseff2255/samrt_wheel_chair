import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  // The main plugin instance — handles all notification operations
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Call this once at app startup (in main.dart)
  static Future<void> initialize() async {
    // Tell Android to use the app's launcher icon for notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);

    // Android 13+ requires explicit permission for notifications
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Red, high-priority notification for emergencies (fall, critical vitals)
  static Future<void> showEmergencyAlert({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'emergency_channel', // Unique channel ID (create once, reuse always)
      'Emergency Alerts', // Channel name shown in Android settings
      channelDescription: 'Critical alerts from the wheelchair system',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      color: Color(0xFFD32F2F), // Red tint on notification
    );

    await _notifications.show(
      0, // Notification ID: 0 = always replace old one
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  // Orange, standard priority for warnings (collision, etc.)
  static Future<void> showWarningAlert({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'warning_channel',
      'Warnings',
      channelDescription: 'Warning alerts from the wheelchair',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFFF57C00),
    );

    await _notifications.show(
      1, // Different ID from emergency so both can appear simultaneously
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }
}
