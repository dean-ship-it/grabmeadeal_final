// lib/services/location_handler.dart

import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'geofence_service.dart';

/// Handles continuous location tracking and delegates
/// geofence checks to GeofenceService.
class LocationHandler {
  final GeofenceService geofenceService;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  StreamSubscription<Position>? _positionStream;

  LocationHandler({
    required this.geofenceService,
    required this.flutterLocalNotificationsPlugin,
  });

  /// Initialize the geofence service and permissions.
  Future<void> initialize() async {
    // Ensure location permissions are granted
    await _ensureLocationPermission();

    // Initialize the geofence notification channel
    await geofenceService.initialize();
  }

  /// Start listening for location updates and check proximity.
  void startTracking(List<Map<String, dynamic>> wishlist) {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50, // meters
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) async {
      await geofenceService.checkProximityAndNotify(position, wishlist);
    });
  }

  /// Stop location tracking.
  void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  /// Request and verify location permissions.
  Future<void> _ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are denied.');
    }
  }
}
