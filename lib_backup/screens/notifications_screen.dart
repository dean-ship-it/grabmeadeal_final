import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.notifications),
          label: const Text('Trigger Notification'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            NotificationService.showInstantNotification(
              id: 1,
              title: '🔥 Deal Alert!',
              body: 'You’re near a store with wishlist deals!',
            );
          },
        ),
      ),
    );
  }
}
