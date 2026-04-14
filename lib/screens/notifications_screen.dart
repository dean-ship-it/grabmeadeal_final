// lib/screens/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.notifications),
          label: const Text("Send Test Notification"),
          onPressed: () {
            NotificationService.instance.showNotification(
              id: 0,
              title: "Test Notification",
              body: "This is a test from NotificationsScreen!",
            );
          },
        ),
      ),
    );
  }
}
