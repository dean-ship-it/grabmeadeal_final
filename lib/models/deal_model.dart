import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'deal_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Deal {
  final String id;
  final String title;
  final String description;
  final double price;
  final double? originalPrice;
  final String category;
  final String subcategory;
  final String vendor;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime? expiresAt;

  Deal({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.category,
    required this.subcategory,
    required this.vendor,
    required this.imageUrl,
    required this.createdAt,
    this.expiresAt,
  });

  factory Deal.fromJson(Map<String, dynamic> json) => _$DealFromJson(json);
  Map<String, dynamic> toJson() => _$DealToJson(this);

  static final converter = FirestoreConverter<Deal>(
    fromFirestore: (snapshot, _) =>
        Deal.fromJson(snapshot.data()!..['id'] = snapshot.id),
    toFirestore: (deal, _) => deal.toJson(),
  );
}
