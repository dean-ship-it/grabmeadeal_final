import 'package:json_annotation/json_annotation.dart';

part 'store_location.g.dart';

@JsonSerializable()
class StoreLocation {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime createdAt;

  StoreLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.createdAt,
  });

  factory StoreLocation.fromJson(Map<String, dynamic> json) =>
      _$StoreLocationFromJson(json);

  Map<String, dynamic> toJson() => _$StoreLocationToJson(this);
}
