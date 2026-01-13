import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 Background message received: ${message.notification?.title}');
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _isInitialized = false;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // FCM not supported on Windows/Linux/macOS desktop
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      print('⚠️ FCM not supported on desktop platforms');
      _isInitialized = true;
      return;
    }

    try {
      // Request notification permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      print('🔔 FCM Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get FCM token
        _fcmToken = await _messaging.getToken();
        print('🔔 FCM Token: $_fcmToken');

        // Save token to Firestore if user is logged in
        await _saveTokenToFirestore();

        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          _saveTokenToFirestore();
        });

        // Set up foreground message handler
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Set up background handler
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

        // Handle notification tap when app is in background/terminated
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        // Check if app was opened from a notification
        RemoteMessage? initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }
      }

      _isInitialized = true;
    } catch (e) {
      print('❌ FCM initialization failed: $e');
      _isInitialized = true; // Mark as initialized to prevent retries
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('🔔 Foreground message: ${message.notification?.title}');
    // Message will be shown automatically by the system
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('🔔 Notification tapped: ${message.data}');
    // Handle navigation based on payload
    // final payload = message.data['type'];
    // Navigate to appropriate screen
  }

  Future<void> _saveTokenToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && _fcmToken != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'fcmToken': _fcmToken,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print('✅ FCM token saved to Firestore');
      }
    } catch (e) {
      print('❌ Failed to save FCM token: $e');
    }
  }

  /// Subscribe to a topic for push notifications
  Future<void> subscribeToTopic(String topic) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      return;
    }
    try {
      await _messaging.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Failed to subscribe to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      return;
    }
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Failed to unsubscribe from topic: $e');
    }
  }

  /// Save reminder settings to Firestore for FCM
  Future<void> saveReminderSettings({
    required bool prayerRemindersEnabled,
    required int prayerReminderMinutes,
    required bool fajrEnabled,
    required bool dhuhrEnabled,
    required bool asrEnabled,
    required bool maghribEnabled,
    required bool ishaEnabled,
    required bool morningDhikrEnabled,
    required String morningDhikrTime,
    required bool eveningDhikrEnabled,
    required String eveningDhikrTime,
    required bool dailyAmalReminderEnabled,
    required String dailyAmalReminderTime,
    double? latitude,
    double? longitude,
    String? timezone,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ User not logged in, cannot save reminder settings');
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('reminders')
          .set({
        'fcmToken': _fcmToken,
        'prayerRemindersEnabled': prayerRemindersEnabled,
        'prayerReminderMinutes': prayerReminderMinutes,
        'fajrEnabled': fajrEnabled,
        'dhuhrEnabled': dhuhrEnabled,
        'asrEnabled': asrEnabled,
        'maghribEnabled': maghribEnabled,
        'ishaEnabled': ishaEnabled,
        'morningDhikrEnabled': morningDhikrEnabled,
        'morningDhikrTime': morningDhikrTime,
        'eveningDhikrEnabled': eveningDhikrEnabled,
        'eveningDhikrTime': eveningDhikrTime,
        'dailyAmalReminderEnabled': dailyAmalReminderEnabled,
        'dailyAmalReminderTime': dailyAmalReminderTime,
        'latitude': latitude,
        'longitude': longitude,
        'timezone': timezone,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ Reminder settings saved to Firestore');
    } catch (e) {
      print('❌ Failed to save reminder settings: $e');
    }
  }

  /// Check if FCM is available
  bool get isAvailable {
    if (kIsWeb) return true;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Request permission status
  Future<bool> hasPermission() async {
    if (!isAvailable) return false;
    
    try {
      NotificationSettings settings = await _messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      return false;
    }
  }
}

// Global FCM service instance
final fcmService = FCMService();
