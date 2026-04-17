import 'package:cloud_firestore/cloud_firestore.dart';

class Deal {
  final String id;
  final String title;
  final String description;
  final String category;
  final String subcategory;
  final String vendor;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final String dealUrl;
  final List<String> keywords;
  final DateTime createdAt;

  Deal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.subcategory,
    required this.vendor,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.dealUrl = '',
    required this.keywords,
    required this.createdAt,
  });

  /// Factory method to build from Firestore JSON.
  /// Handles both old field names (imageUrl, date, price) and
  /// new field names (link, createdAt, priceCurrent).
  factory Deal.fromJson(Map<String, dynamic> json, String id) {
    // price: try 'priceCurrent' (new) then 'price' (old)
    final rawPrice = json['priceCurrent'] ?? json['price'];
    final double price = (rawPrice is int)
        ? rawPrice.toDouble()
        : (rawPrice as num? ?? 0.0).toDouble();

    // originalPrice: unchanged field name
    final rawOriginal = json['originalPrice'];
    final double? originalPrice = rawOriginal != null
        ? (rawOriginal is int)
            ? rawOriginal.toDouble()
            : (rawOriginal as num).toDouble()
        : null;

    // imageUrl: try 'imageUrl' only
    final String imageUrl = json['imageUrl'] ?? '';

    // dealUrl: affiliate/vendor link
    final String dealUrl =
        json['dealUrl'] ?? json['affiliateUrl'] ?? json['url'] ?? json['link'] ?? '';

    // createdAt: try 'createdAt' (new) then 'date' (old)
    final rawDate = json['createdAt'] ?? json['date'];
    final DateTime createdAt = (rawDate is Timestamp)
        ? rawDate.toDate()
        : (rawDate is String)
            ? DateTime.tryParse(rawDate) ?? DateTime.now()
            : DateTime.now();

    return Deal(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      vendor: json['vendor'] ?? '',
      price: price,
      originalPrice: originalPrice,
      imageUrl: imageUrl,
      dealUrl: dealUrl,
      keywords: json['keywords'] != null
          ? List<String>.from(json['keywords'])
          : [],
      createdAt: createdAt,
    );
  }

  /// Factory method to build from a Firestore document snapshot.
  factory Deal.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return Deal.fromJson(doc.data(), doc.id);
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'subcategory': subcategory,
      'vendor': vendor,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'dealUrl': dealUrl,
      'keywords': keywords.map((k) => k.toLowerCase()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
