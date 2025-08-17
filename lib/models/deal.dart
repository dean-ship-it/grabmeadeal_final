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
    required this.keywords,
    required this.createdAt,
  });

  /// Factory method to build from Firestore JSON
  factory Deal.fromJson(Map<String, dynamic> json, String id) {
    return Deal(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      vendor: json['vendor'] ?? '',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] ?? 0.0).toDouble(),
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] is int)
              ? (json['originalPrice'] as int).toDouble()
              : (json['originalPrice'] as num).toDouble()
          : null,
      imageUrl: json['imageUrl'] ?? '',
      keywords: (json['keywords'] != null)
          ? List<String>.from(json['keywords'])
          : [],
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
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
      'keywords': keywords.map((k) => k.toLowerCase()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
