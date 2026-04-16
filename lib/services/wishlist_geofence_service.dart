import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:grabmeadeal_final/models/deal.dart';

/// A service that monitors the user’s location and triggers notifications
/// if a wishlist deal matches a nearby store.
///
/// Uses:
/// - Geolocator for GPS
/// - FlutterLocalNotificationsPlugin for local push alerts
class WishlistGeofenceService {

  WishlistGeofenceService({
    required this.wishlistDeals,
    required FlutterLocalNotificationsPlugin notifications,
  }) : _notifications = notifications;
  final List<Deal> wishlistDeals;
  final FlutterLocalNotificationsPlugin _notifications;

  StreamSubscription<Position>? _positionStream;

  /// Start monitoring location and checking geofences
  Future<void> startMonitoring() async {
    final bool hasPermission = await _ensureLocationPermission();
    if (!hasPermission) return;

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50, // update every 50m
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        _checkDealsNearby(position);
      },
    );
  }

  /// Stop monitoring
  Future<void> stopMonitoring() async {
    await _positionStream?.cancel();
  }

  /// Ensure location permission is granted
  Future<bool> _ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  /// Check if current position is near any store related to wishlist deals
  void _checkDealsNearby(Position position) {
    // 🚨 Demo logic: in real system, vendor geolocations come from Firestore
    const double mockStoreLat = 29.7604; // Example: Houston lat
    const double mockStoreLng = -95.3698; // Example: Houston lng

    final double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      mockStoreLat,
      mockStoreLng,
    );

    if (distance < 500) {
      // within 500 meters
      for (final Deal deal in wishlistDeals) {
        _triggerNotification(deal);
      }
    }
  }

  /// Fire a local notification for the given deal
  Future<void> _triggerNotification(Deal deal) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'wishlist_channel',
      'Wishlist Deals',
      channelDescription: 'Notifications when nearby stores have wishlist deals',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      deal.id.hashCode,
      'Nearby Deal Alert!',
      '${deal.title} available at ${deal.vendor} for \$${deal.price.toStringAsFixed(2)}',
      details,
    );
  }
}
