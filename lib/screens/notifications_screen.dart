// lib/screens/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            NotificationService.showNotification(
              title: 'Grab Me A Deal',
              body: 'A nearby store has a deal on your wishlist!',
            );
          },
          child: const Text('Send Test Notification'),
        ),
      ),
    );
  }
}
