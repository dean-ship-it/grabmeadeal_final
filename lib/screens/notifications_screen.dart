import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  final String id;

  const NotificationsScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            NotificationService.showNotification(
              id: id,
              title: 'Deal Nearby!',
              body: 'You’re close to a store with a wishlist deal.',
            );
          },
          child: const Text('Test Notification'),
        ),
      ),
    );
  }
}
