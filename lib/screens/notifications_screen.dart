import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications Test'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            NotificationService().showNotification(
              id: 1,
              title: 'Test Notification',
              body: 'This is a local push test!',
            );
          },
          child: const Text('Send Test Notification'),
        ),
      ),
    );
  }
}
