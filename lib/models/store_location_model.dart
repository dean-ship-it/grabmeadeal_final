import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'store_location_model.g.dart';

@JsonSerializable(explicitToJson: true)
class StoreLocation {
  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? website;

  StoreLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.website,
  });

  factory StoreLocation.fromJson(Map<String, dynamic> json) =>
      _$StoreLocationFromJson(json);
  Map<String, dynamic> toJson() => _$StoreLocationToJson(this);

  static final converter = FirestoreConverter<StoreLocation>(
    fromFirestore: (snapshot, _) =>
        StoreLocation.fromJson(snapshot.data()!..['id'] = snapshot.id),
    toFirestore: (store, _) => store.toJson(),
  );
}
