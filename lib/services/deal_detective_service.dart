// lib/services/deal_detective_service.dart
// Deal Detective — your personal AI shopping assistant
// Monitors location, detects nearby stores, and verbally alerts
// users about deals they care about.

import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';

// ── Store Location Database ──────────────────────────────────────────────────
// Major retail stores in Texas metro areas (Houston, Dallas, SA, Austin)

class StoreLocation {
  final String name;
  final String category; // maps to DealCategory
  final double lat;
  final double lng;
  final String city;

  const StoreLocation({
    required this.name,
    required this.category,
    required this.lat,
    required this.lng,
    required this.city,
  });
}

// Texas store locations — expand this list over time
const List<StoreLocation> _texasStores = [
  // ── Houston ──
  // Walmart
  StoreLocation(name: "Walmart", category: "grocery", lat: 29.7604, lng: -95.3698, city: "Houston"),
  StoreLocation(name: "Walmart Supercenter", category: "grocery", lat: 29.7285, lng: -95.4750, city: "Houston"),
  StoreLocation(name: "Walmart Supercenter", category: "grocery", lat: 29.8395, lng: -95.4103, city: "Houston"),
  StoreLocation(name: "Walmart Supercenter", category: "grocery", lat: 29.6822, lng: -95.2774, city: "Houston"),
  // HEB
  StoreLocation(name: "HEB", category: "grocery", lat: 29.7493, lng: -95.3588, city: "Houston"),
  StoreLocation(name: "HEB", category: "grocery", lat: 29.7914, lng: -95.4681, city: "Houston"),
  StoreLocation(name: "HEB Plus", category: "grocery", lat: 29.6630, lng: -95.5488, city: "Houston"),
  StoreLocation(name: "HEB", category: "grocery", lat: 29.8530, lng: -95.3946, city: "Houston"),
  // Target
  StoreLocation(name: "Target", category: "homeGoods", lat: 29.7355, lng: -95.4103, city: "Houston"),
  StoreLocation(name: "Target", category: "homeGoods", lat: 29.7969, lng: -95.4092, city: "Houston"),
  // Best Buy
  StoreLocation(name: "Best Buy", category: "electronics", lat: 29.7383, lng: -95.4214, city: "Houston"),
  StoreLocation(name: "Best Buy", category: "electronics", lat: 29.7926, lng: -95.4655, city: "Houston"),
  // Home Depot
  StoreLocation(name: "Home Depot", category: "tools", lat: 29.7503, lng: -95.3663, city: "Houston"),
  StoreLocation(name: "Home Depot", category: "tools", lat: 29.7764, lng: -95.4539, city: "Houston"),
  // Academy Sports
  StoreLocation(name: "Academy Sports", category: "fitness", lat: 29.7228, lng: -95.4378, city: "Houston"),
  StoreLocation(name: "Academy Sports", category: "fitness", lat: 29.8142, lng: -95.4060, city: "Houston"),
  // Costco
  StoreLocation(name: "Costco", category: "grocery", lat: 29.7285, lng: -95.4630, city: "Houston"),
  StoreLocation(name: "Costco", category: "grocery", lat: 29.7922, lng: -95.4658, city: "Houston"),
  // AutoZone
  StoreLocation(name: "AutoZone", category: "automotive", lat: 29.7515, lng: -95.3536, city: "Houston"),
  // PetSmart
  StoreLocation(name: "PetSmart", category: "petSupplies", lat: 29.7391, lng: -95.4227, city: "Houston"),
  // Ulta Beauty
  StoreLocation(name: "Ulta Beauty", category: "beauty", lat: 29.7389, lng: -95.4139, city: "Houston"),
  // IKEA
  StoreLocation(name: "IKEA", category: "furniture", lat: 29.6856, lng: -95.4712, city: "Houston"),
  // GameStop
  StoreLocation(name: "GameStop", category: "gaming", lat: 29.7358, lng: -95.4135, city: "Houston"),

  // ── Dallas ──
  StoreLocation(name: "Walmart", category: "grocery", lat: 32.7767, lng: -96.7970, city: "Dallas"),
  StoreLocation(name: "HEB", category: "grocery", lat: 32.8655, lng: -96.8318, city: "Dallas"),
  StoreLocation(name: "Target", category: "homeGoods", lat: 32.7944, lng: -96.8064, city: "Dallas"),
  StoreLocation(name: "Best Buy", category: "electronics", lat: 32.7936, lng: -96.7888, city: "Dallas"),
  StoreLocation(name: "Home Depot", category: "tools", lat: 32.8119, lng: -96.7984, city: "Dallas"),
  StoreLocation(name: "Academy Sports", category: "fitness", lat: 32.7709, lng: -96.8262, city: "Dallas"),
  StoreLocation(name: "Costco", category: "grocery", lat: 32.8607, lng: -96.7684, city: "Dallas"),

  // ── San Antonio ──
  StoreLocation(name: "HEB", category: "grocery", lat: 29.4241, lng: -98.4936, city: "San Antonio"),
  StoreLocation(name: "HEB Plus", category: "grocery", lat: 29.5100, lng: -98.5710, city: "San Antonio"),
  StoreLocation(name: "Walmart", category: "grocery", lat: 29.4564, lng: -98.5140, city: "San Antonio"),
  StoreLocation(name: "Target", category: "homeGoods", lat: 29.5108, lng: -98.5250, city: "San Antonio"),
  StoreLocation(name: "Best Buy", category: "electronics", lat: 29.5079, lng: -98.5234, city: "San Antonio"),
  StoreLocation(name: "Academy Sports", category: "fitness", lat: 29.5191, lng: -98.4990, city: "San Antonio"),

  // ── Austin ──
  StoreLocation(name: "HEB", category: "grocery", lat: 30.2672, lng: -97.7431, city: "Austin"),
  StoreLocation(name: "HEB Plus", category: "grocery", lat: 30.3505, lng: -97.7395, city: "Austin"),
  StoreLocation(name: "Walmart", category: "grocery", lat: 30.2988, lng: -97.7083, city: "Austin"),
  StoreLocation(name: "Target", category: "homeGoods", lat: 30.3035, lng: -97.7369, city: "Austin"),
  StoreLocation(name: "Best Buy", category: "electronics", lat: 30.3610, lng: -97.7280, city: "Austin"),
  StoreLocation(name: "Costco", category: "grocery", lat: 30.4014, lng: -97.7244, city: "Austin"),
  StoreLocation(name: "Academy Sports", category: "fitness", lat: 30.3530, lng: -97.7354, city: "Austin"),
];

// ── Deal Detective Service ───────────────────────────────────────────────────

class DealDetectiveService {
  DealDetectiveService._internal();
  static final DealDetectiveService instance = DealDetectiveService._internal();

  final FlutterTts _tts = FlutterTts();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<Position>? _positionStream;
  bool _initialized = false;
  bool _isActive = false;

  // Track which stores we've already alerted (prevent spam)
  final Set<String> _alertedStores = {};
  // Cooldown timer — reset alerted stores every 2 hours
  Timer? _cooldownTimer;

  // Detection radius in meters
  static const double _detectionRadiusMeters = 500; // ~0.3 miles
  // Minimum time between alerts (seconds)
  static const int _minAlertIntervalSeconds = 120;
  DateTime? _lastAlertTime;

  // ── Initialize ──

  Future<void> init() async {
    if (_initialized) return;

    // Set up TTS — friendly female voice, conversational pace
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.45); // Slightly slower than default — friendly
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.1); // Slightly higher pitch — warm and friendly

    // Try to get a female voice
    final voices = await _tts.getVoices;
    if (voices is List) {
      for (final voice in voices) {
        if (voice is Map) {
          final name = (voice["name"] ?? "").toString().toLowerCase();
          final locale = (voice["locale"] ?? "").toString().toLowerCase();
          if (locale.contains("en-us") &&
              (name.contains("female") || name.contains("samantha") || name.contains("zira"))) {
            await _tts.setVoice({"name": voice["name"], "locale": voice["locale"]});
            break;
          }
        }
      }
    }

    // Set up notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _notifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    _initialized = true;
    debugPrint("[DealDetective] Initialized — ready to detect deals!");
  }

  // ── Start Monitoring ──

  Future<void> startDetecting() async {
    if (_isActive) return;
    await init();

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      debugPrint("[DealDetective] Location permission denied");
      return;
    }

    _isActive = true;
    _alertedStores.clear();

    // Reset alerted stores every 2 hours so the same store can alert again
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(
      const Duration(hours: 2),
      (_) => _alertedStores.clear(),
    );

    // Listen for position changes
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50, // Update every 50 meters of movement
      ),
    ).listen(_onPositionUpdate);

    debugPrint("[DealDetective] 🔍 Now detecting nearby deals...");
  }

  // ── Stop Monitoring ──

  Future<void> stopDetecting() async {
    _isActive = false;
    await _positionStream?.cancel();
    _positionStream = null;
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    _alertedStores.clear();
    debugPrint("[DealDetective] Stopped detecting");
  }

  // ── Position Update Handler ──

  Future<void> _onPositionUpdate(Position position) async {
    if (!_isActive) return;

    // Find nearby stores
    for (final store in _texasStores) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        store.lat,
        store.lng,
      );

      if (distance <= _detectionRadiusMeters) {
        // Create a unique key for this store location
        final storeKey = "${store.name}_${store.lat}_${store.lng}";

        if (!_alertedStores.contains(storeKey)) {
          // Check rate limiting
          final now = DateTime.now();
          if (_lastAlertTime != null &&
              now.difference(_lastAlertTime!).inSeconds < _minAlertIntervalSeconds) {
            continue; // Too soon since last alert
          }

          _alertedStores.add(storeKey);
          _lastAlertTime = now;

          // Find deals matching this store's category
          await _alertNearbyDeal(store, distance);
        }
      }
    }
  }

  // ── Alert: Nearby Deal Found ──

  Future<void> _alertNearbyDeal(StoreLocation store, double distanceMeters) async {
    // Query Firestore for deals in this store's category or vendor
    final deals = await _findDealsForStore(store);

    String spokenMessage;
    String notificationBody;
    final distanceText = distanceMeters < 200
        ? "right here"
        : "${(distanceMeters / 1609.34).toStringAsFixed(1)} miles away";

    if (deals.isNotEmpty) {
      final deal = deals[Random().nextInt(deals.length)]; // Pick a random matching deal
      final title = deal["title"] ?? "a great deal";
      final savings = _calculateSavings(deal);

      spokenMessage = _buildSpokenAlert(store.name, title, savings, distanceText);
      notificationBody = "🔥 ${store.name} has $title"
          "${savings != null ? ' — save \$${savings.toStringAsFixed(0)}!' : '!'}"
          " Tap to view the deal.";
    } else {
      spokenMessage =
          "Hey! You're near ${store.name}. "
          "Check the app for deals in their ${_categoryLabel(store.category)} section!";
      notificationBody =
          "📍 You're near ${store.name}! Check for ${_categoryLabel(store.category)} deals.";
    }

    // Show notification
    await _showDealNotification(
      title: "🔍 Deal Detective",
      body: notificationBody,
    );

    // Speak the alert
    await _speak(spokenMessage);

    debugPrint("[DealDetective] 🔔 Alerted: ${store.name} ($distanceText)");
  }

  // ── Build Natural Spoken Alerts ──

  String _buildSpokenAlert(
    String storeName,
    String dealTitle,
    double? savings,
    String distanceText,
  ) {
    final greetings = [
      "Hey!",
      "Heads up!",
      "Quick deal alert!",
      "Oooh, check this out!",
      "Deal Detective here!",
    ];
    final closings = [
      "Want to swing by before it's gone?",
      "Might be worth a quick stop!",
      "Just a thought while you're nearby!",
      "It's right on your way!",
      "Don't miss out!",
    ];

    final greeting = greetings[Random().nextInt(greetings.length)];
    final closing = closings[Random().nextInt(closings.length)];

    if (savings != null && savings > 5) {
      return "$greeting There's a $storeName $distanceText "
          "with ${savings.toStringAsFixed(0)} dollars off $dealTitle. "
          "$closing";
    } else {
      return "$greeting $storeName is $distanceText "
          "and they have $dealTitle on sale right now. "
          "$closing";
    }
  }

  // ── Find Matching Deals ──

  Future<List<Map<String, dynamic>>> _findDealsForStore(StoreLocation store) async {
    try {
      // First try matching by vendor name
      var snap = await FirebaseFirestore.instance
          .collection("deals")
          .where("vendor", isEqualTo: store.name)
          .limit(5)
          .get();

      if (snap.docs.isNotEmpty) {
        return snap.docs.map((d) => d.data()).toList();
      }

      // Fallback: match by category
      snap = await FirebaseFirestore.instance
          .collection("deals")
          .where("category", isEqualTo: store.category)
          .limit(5)
          .get();

      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      debugPrint("[DealDetective] Error querying deals: $e");
      return [];
    }
  }

  // ── Helpers ──

  double? _calculateSavings(Map<String, dynamic> deal) {
    final original = (deal["originalPrice"] ?? deal["priceWas"]) as num?;
    final current = (deal["price"] ?? deal["priceCurrent"]) as num?;
    if (original != null && current != null && original > current) {
      return (original - current).toDouble();
    }
    return null;
  }

  String _categoryLabel(String category) {
    const labels = {
      "electronics": "electronics",
      "grocery": "grocery",
      "beauty": "beauty",
      "apparel": "clothing",
      "tools": "tools and hardware",
      "automotive": "automotive",
      "furniture": "furniture",
      "fitness": "fitness and sports",
      "gaming": "gaming",
      "petSupplies": "pet supplies",
      "homeGoods": "home and kitchen",
    };
    return labels[category] ?? category;
  }

  Future<void> _speak(String message) async {
    try {
      await _tts.speak(message);
    } catch (e) {
      debugPrint("[DealDetective] TTS error: $e");
    }
  }

  Future<void> _showDealNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'deal_detective_channel',
      'Deal Detective Alerts',
      channelDescription: 'Nearby deal alerts from Deal Detective',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.recommendation,
      styleInformation: BigTextStyleInformation(''),
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  // ── Status ──

  bool get isActive => _isActive;
  int get storesInDatabase => _texasStores.length;
  int get alertedCount => _alertedStores.length;
}
