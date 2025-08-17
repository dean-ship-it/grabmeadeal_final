import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grabmeadeal_final/services/notification_service.dart';

class TestNotificationScreen extends StatefulWidget {
  const TestNotificationScreen({super.key});

  @override
  State<TestNotificationScreen> createState() => _TestNotificationScreenState();
}

class _TestNotificationScreenState extends State<TestNotificationScreen> {
  String _status = '📍 Checking location...';
  final double _targetLat = 29.7604; // Example: Houston (H-E-B)
  final double _targetLng = -95.3698;
  final double _radiusMeters = 500;

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      final Position position = await Geolocator.getCurrentPosition();

      final double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        _targetLat,
        _targetLng,
      );

      if (distance <= _radiusMeters) {
        NotificationService.showNotification(
          id: 2,
          title: '🎯 Nearby Deal Match!',
          body: 'You’re near H-E-B. Your wishlist has matching items!',
        );
        setState(() => _status = '🎉 You’re inside the geofence zone.');
      } else {
        setState(() => _status =
            '📍 Outside geofence. Distance: ${distance.toStringAsFixed(0)}m',);
      }
    } else {
      setState(() => _status = '❌ Location permission denied.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📍 Geofence Test'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Center(
        child: Text(
          _status,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
