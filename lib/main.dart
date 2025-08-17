// lib/main.dart

import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/services/notification_service.dart';
import 'package:grabmeadeal_final/services/location_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications first
  await NotificationService().initialize();

  // Initialize location/geofence logic
  final locationHandler = LocationHandler();
  await locationHandler.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grab Me A Deal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grab Me A Deal"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            NotificationService().showNotification(
              title: "Test Notification",
              body: "This is a test push from HomeScreen",
            );
          },
          child: const Text("Send Test Notification"),
        ),
      ),
    );
  }
}
