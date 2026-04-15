// lib/services/notification_service.dart

import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";

@pragma("vm:entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("[FCM Background] ${message.messageId}: ${message.notification?.title}");
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  static const _channelId = "grabmeadeal_default";
  static const _channelName = "GrabMeADeal Alerts";
  static const _channelDesc = "Deal alerts and store notifications";

  Future<void> initialize() async {
    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Skip permission request on web — the browser dialog blocks rendering.
      // Web notifications are handled separately via the service worker.
      if (!kIsWeb) {
        await _fcm.requestPermission(alert: true, badge: true, sound: true);
      }

      if (!kIsWeb) {
        const androidChannel = AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.high,
        );

        await _local
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(androidChannel);

        const androidInit = AndroidInitializationSettings("@mipmap/ic_launcher");
        await _local.initialize(
          const InitializationSettings(android: androidInit),
          onDidReceiveNotificationResponse: _onNotificationTap,
        );
      }

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

      final initial = await _fcm.getInitialMessage();
      if (initial != null) _handleNotificationOpen(initial);

      final token = await _fcm.getToken();
      debugPrint("[FCM Token] $token");
    } catch (e, stack) {
      debugPrint("[NotificationService] initialization failed: $e\n$stack");
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    _showLocal(title: n.title ?? "GrabMeADeal", body: n.body ?? "");
  }

  void _handleNotificationOpen(RemoteMessage message) {
    debugPrint("[FCM Opened] ${message.data}");
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint("[Local Tap] payload=${response.payload}");
  }

  Future<void> _showLocal({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    await _local.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: "@mipmap/ic_launcher",
        ),
      ),
      payload: payload,
    );
  }

  void showNotification({
    BuildContext? context,
    required String title,
    required String body,
    int? id,
    String? payload,
  }) {
    if (context != null) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger != null) {
        messenger.showSnackBar(SnackBar(content: Text("$title: $body")));
        return;
      }
    }
    _showLocal(title: title, body: body, id: id ?? 0, payload: payload);
  }

  void showStoreClosingAlert({
    required BuildContext context,
    required String storeName,
    required int minutesUntilClose,
  }) {
    showNotification(
      context: context,
      title: "Closing Soon",
      body: "$storeName closes in $minutesUntilClose minutes",
    );
  }

  Future<void> subscribeToDealsChannel() async {
    try {
      await _fcm.subscribeToTopic("deals_alerts");
      debugPrint("[FCM] Subscribed to deals_alerts topic");
    } catch (e) {
      debugPrint("[FCM] Subscribe error: $e");
    }
  }

  Future<void> start() async {}
  Future<void> stop() async {}
}
