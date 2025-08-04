import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class GeofenceService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  GeofenceService({required this.flutterLocalNotificationsPlugin});

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> checkProximityAndNotify(
    Position currentPosition,
    List<Map<String, dynamic>> wishlist,
  ) async {
    for (var item in wishlist) {
      double storeLat = item['storeLat'];
      double storeLng = item['storeLng'];
      String storeName = item['storeName'];
      String dealTitle = item['dealTitle'];

      double distanceInMeters = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        storeLat,
        storeLng,
      );

      if (distanceInMeters < 500) {
        await _showNotification(
          title: 'Nearby Deal!',
          body: '$dealTitle is on sale at $storeName nearby!',
        );
        break; // Only notify once per check
      }
    }

    // TODO: Add logic to check if the position is near any wishlist store.
  }

  Future<void> _showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'geofence_channel',
      'Geofence Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
    );
  }
}
