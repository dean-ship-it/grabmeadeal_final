// lib/models/deal.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Deal {
  final String id;
  final String title;
  final String description;
  final double price;
  final double originalPrice;
  final String imageUrl;
  final String vendor;
  final String link;
  final String category;
  final double? latitude;
  final double? longitude;
  final DateTime date;

  Deal({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.imageUrl,
    required this.vendor,
    required this.link,
    required this.category,
    this.latitude,
    this.longitude,
    required this.date,
  });

  /// Creates a Deal from a Firestore document.
  factory Deal.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Deal(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (data['originalPrice'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] as String? ?? '',
      vendor: data['vendor'] as String? ?? '',
      link: data['link'] as String? ?? '',
      category: data['category'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts this Deal into a map for uploading.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'vendor': vendor,
      'link': link,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'date': Timestamp.fromDate(date),
    };
  }
}
