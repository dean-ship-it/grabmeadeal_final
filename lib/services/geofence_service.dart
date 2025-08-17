import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class GeofenceService {
  GeofenceService._internal();
  static final GeofenceService instance = GeofenceService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<Position>? _positionStream;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await _handleLocationPermission();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);
    await _notifications.initialize(initSettings);

    _initialized = true;
  }

  Future<void> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }

    if (Platform.isIOS) {
      // Ensure Info.plist contains NSLocationAlwaysUsageDescription,
      // NSLocationWhenInUseUsageDescription, and UIBackgroundModes: location
    }
  }

  Future<void> startGeofence({
    required String id,
    required double latitude,
    required double longitude,
    required double radiusMeters,
    String? triggerMessage,
  }) async {
    await init();

    _positionStream?.cancel();

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 25,
      ),
    ).listen((Position pos) {
      final distance = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        latitude,
        longitude,
      );

      if (distance <= radiusMeters) {
        _showNotification(
          title: "Deal Nearby!",
          body: triggerMessage ?? "You’ve entered a deal zone.",
        );
      }
    });
  }

  Future<void> stopGeofence() async {
    await _positionStream?.cancel();
    _positionStream = null;
  }

  Future<void> _showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'geofence_channel',
      'Geofence Notifications',
      channelDescription: 'Notifications for nearby deals',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}
